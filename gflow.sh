##################### Global Variables & Function  ###################
gflow_folder_name="./.gflow"
config_file="$gflow_folder_name/config.json"
temp_changelog_file="$gflow_folder_name/temp_changelog.md"


function error_color {
    tput setaf 1; 
}

function warning_color {
    tput setaf 3; 
}

function success_color {
    tput setaf 2; 
}

function highlight_color {
    tput setaf 5; 
}

function ordinary_color {
    tput sgr0;
}

function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

function get_current_version {
    tmp_v=$(sed -n 's/.*"version": "\([^"]*\)"/\1/p' $config_file)
    tmp_v=( ${tmp_v//./ } ) 
}

function pump_version {
    version="$1"
     echo "
    {
        \"version\": \"$version\"
    }
    " > $config_file
}

function create_cli_directory {
    mkdir "$gflow_folder_name"
}

function create_file {
    touch "$1"
}

function commit_code {
    commit_param_1="$1"
    vim $temp_changelog_file
    if  does_temp_changelog_exists; then
        is_modified="$(git diff $temp_changelog_file)"
        if [ -z "$is_modified" ]; then
            warn_about_empty_changelog
        else
            commit_message="$(git diff --color $temp_changelog_file | perl -wlne 'print $1 if /^\e\[32m\+\e\[m\e\[32m(.*)\e\[m$/')"
            success_color
            echo "Commit Message"
            echo "=========================="
            echo "$commit_message"
            ordinary_color
            if [ "$commit_param_1" = "load_stashed" ]; then
                load_stashed 
            fi
            git add .
            git commit -m "$commit_message"
        fi
    else
        warn_about_empty_changelog
    fi    
}

function warn_about_empty_changelog {
    error_color
    echo "You have to update the temp changelog in order to commit your work 🚨"
    echo "Updated Change log will be used in commit message 💬"
    ordinary_color
    options=("1- try again ⚙️" "2- Abort Commit 🛑🚦")
    select_option "${options[@]}"    
    choice=$?
    case $choice in
        0) commit_code load_stashed;;
        1) abort_commit;;
    esac
}

function reset_changelog {
    rm "$temp_changelog_file"
    create_file $temp_changelog_file
     echo "
# Temp Changelog
This File Will Contain the Temp Change log until this version get deployed, items in this change log will be added to your commit message by default

## [Unreleased]
## [$version] - $(date +%F_%H:%M:%S)

### Added
[A]- 
[A]-
[A]-
[A]-

### Changed
[C]- 
[C]-
[C]-
[C]-

### Removed
[R]- 
[R]-
[R]-
[R]-

### Deprecated
[D]- 
[D]-
[D]-
[D]-

### Fixed
[F]-
[F]-
[F]-
[F]-

### Security
[S]-
[S]-
[S]-
[S]-
         
    " > $temp_changelog_file
    
}

function does_temp_changelog_exists {
    if [ -e "$temp_changelog_file" ]; then
        return 0
    else
        return 1
    fi
}

function abort_commit {
    error_color
    echo "Commit Has Been Aborted!!"    
    git checkout $snapshot_current_branch              
    if [ $snapshot_has_changes = true ] && [ $snapshot_changes_stashed = true ]; then
        load_stashed
    fi            
}

function take_snapshot {
    
    snapshot_current_branch="$(git symbolic-ref --short -q HEAD)"
     if [ -z "$(git status --porcelain)" ]; then 
        snapshot_has_changes["has_changes"]=true
    else
        snapshot_has_changes=false
    fi    
}

function stash_changes {
    git stash save -u # to stash untracked files
    snapshot_changes_stashed=true
}

function load_stashed {
    git stash apply # apply the last stash without deleting it
    snapshot_changes_stashed=false
}

function print_guidlines {
     echo "
Wrong command, these are the commands supported so far
        - init              Init the Project's Workflow
        - commit            Do a Commit Flow
        - create_release    Create Release Branch Release Flow
        - create_feature    Create Feature Flow  
        - create_hotfix     Create Hotfix Flow
        - version           Get current prject version
    "
}
##################### Init Command Begin  ###################

function init {
    echo "$config_file"
    if [ -e "$config_file" ]; then
        if [ "$1" = "--f" ]; then
            perform_flow_init
        else
            echo "Workflow Already Initialized, in order to re intialize write"
            highlight_color
            echo "  - gflow init --f"
        fi    
    else
        perform_flow_init    
    fi
}

function perform_flow_init {
    is_new_project
    if [ "$is_new_project" = "Y" ]; then
        create_config_file
    else
        ask_user_version        
    fi
}

function is_new_project {
    echo "GFlow is not yet initialized for this Project."
    echo "Is this a new project that you want to initialize?(Y, n):"
    read is_new_project
}

function create_config_file {
    if [ -z "$1" ]; then
        version=0.1.0
    else
        version=$1
    fi    
    create_cli_directory
    create_file "$config_file"
    pump_version $version    
    echo "Gflow Config File Intialized with version ($version)"
    git add .
    git commit -m"Config file initializd"
}

function ask_user_version {
    echo "What is the current version of your project?"
    read entered_version
    is_valid_version
}

function is_valid_version {
    rx=^[0-9]+\.[0-9]+
    if [[ "$entered_version" =~ $rx ]]; then
        create_config_file $entered_version
    else
        error_color
        echo "ERROR:<->Version Number is not valid: '$entered_version'"    
        echo "Version number should be something like 3.2.88'"    
        ordinary_color        
        ask_user_version
    fi
}

##################### Init Command End  ###################

##################### Commit Command Begin  ###################

function commit {
    take_snapshot
    if [ -z "$(git status --porcelain)" ]; then 
        echo "$(git status)"
    else 
        current_branch="$(git symbolic-ref --short -q HEAD)"
        is_protected_branch
    fi
}

function is_protected_branch {
    if [ "$current_branch" = "master" ] || [ "$current_branch" = "develop" ]; then
        show_wrong_branch_warning        
        ask_for_commit_type
    else
        echo "You are currently on branch ${current_branch}, do you want to commit these changes to it?"
        options=("1- Yes 👍" "2- No 👎")
        select_option "${options[@]}"
        choice=$?
        case $choice in
            0) commit_changes_to_current_branch;;
            1) ask_for_commit_type;;            
        esac
    fi

}

function show_wrong_branch_warning {
    error_color
    echo "$current_branch branch is a protected branch; you can't commit to it!!!"
    echo "For more info about the gitflow used, check the link below 👇"
    highlight_color
    echo "https://nvie.com/posts/a-successful-git-branching-model/"
    ordinary_color
}

function check_if_any_update_exists {
    status="$(git status)"
    status=( ${status//,/ } )
    echo "${status}"
    echo "${status[5]}"
}

function ask_for_commit_type {
    echo "Please choose the type of your commit from the options below to CONTINUE 👇"
    options=("1- Hot fix 🔧" "2- New Feature ⚙️")
    select_option "${options[@]}"
    choice=$?
    case $choice in
        0) create_hotfix;;
        1) create_feature;;
    esac
}

function commit_changes_to_current_branch {
    stash_changes
    commit_code load_stashed
}

##################### Commit Command End  ###################

##################### Create_Release Command Begin  ###################

function create_release {
    take_snapshot
    git checkout develop
    get_current_version
    echo "The current version of the develop branch is ${tmp_v[0]}.${tmp_v[1]}.${tmp_v[2]}, which one you want to assign for the new release?!"
    version_option_1="$((tmp_v[0] + 1)).0.0"
    version_option_2="${tmp_v[0]}.$((tmp_v[1] + 1)).0"
    version_option_3="${tmp_v[0]}.${tmp_v[1]}.$((tmp_v[2] + 1))"
    options=("$version_option_1" "$version_option_2" "$version_option_3")
    select_option "${options[@]}"
    choice=$?
    create_release_branch_with_version ${options[$choice]}
    
}   

function create_release_branch_with_version {
    release_version="$1"
    release_branch_name="release-$release_version"    
    if [ `git branch --list $release_branch_name` ]; then
        warning_color        
        echo "Branch name $release_branch_name already exists." 
        ordinary_color
        git checkout $release_branch_name
    else
        success_color   
        git checkout -b $release_branch_name develop     
        echo "New Branch $release_branch_name has been created" 
        pump_version $release_version ## pump version 
        git add .
        git commit -m"
        Pump Version from $old_v to $new_v
        "
        echo "Version $new_v pumped & commited"
        ordinary_color
    fi           
}


##################### Create_Release Command End  ###################

##################### Create_Feature Command Begin  ###################

function create_feature { 
    take_snapshot   
    echo "What do you want to call this feature branch?"
    feature_branch_name="$(ask_for_feature_branch_name)"
    ## check if branch name contains any restricted names
    if [ -z "$(git status --porcelain)" ]; then 
        checkout_feature_branch $feature_branch_name 
    else
        stash_changes
        checkout_feature_branch $feature_branch_name 
        commit_code load_stashed
    fi
}

function ask_for_feature_branch_name {
    local __feature_branch_name
    read __feature_branch_name  
    echo "$__feature_branch_name"
}

function checkout_feature_branch {
    echo $feature_branch_name
    local feature_branch_name="$1"
    ### check if remote branch exitsts
    if [ `git branch --list $feature_branch_name` ]; then
        warning_color        
        echo "Branch name $feature_branch_name already exists." 
        ordinary_color
        git checkout $feature_branch_name
    else
        success_color        
        git checkout -b $feature_branch_name develop
        echo "New Branch $feature_branch_name has been created" 
        reset_changelog ## Reset Changelog File
        git add .
        git commit -m"
        Reset Changelog for this new branch
        "
        ordinary_color
    fi           
}


##################### Create_Feature Command End  ###################

##################### Create_hotfix Command Begin  ###################
function create_hotfix {
    take_snapshot
     if [ -z "$(git status --porcelain)" ]; then 
        checkout_hotfix_branch
    else
        stash_changes
        checkout_hotfix_branch
        commit_code load_stashed
    fi
}

function checkout_hotfix_branch {
    git checkout master
    get_current_version
    ((tmp_v[2]++)) ## increment Patch version number    
    new_v="${tmp_v[0]}.${tmp_v[1]}.${tmp_v[2]}"
    hotfix_branch_name="hotfix-$new_v"    
    ### check if remote branch exitsts
    if [ `git branch --list $hotfix_branch_name` ]; then
        warning_color        
        echo "Branch name $hotfix_branch_name already exists." 
        ordinary_color
        git checkout $hotfix_branch_name
    else
        success_color        
        git checkout -b $hotfix_branch_name
        echo "New Branch $hotfix_branch_name has been created" 
        pump_version $new_v ## pump version 
        reset_changelog ## Reset Changelog File
        git add .
        git commit -m"
        Pump Version from $old_v to $new_v
        "
        echo "Version $new_v pumped & commited"
        ordinary_color
    fi           
}


##################### Create_hotfix Command End  ###################

cmd=$1
subcmd=$2
if [ -z "$cmd" ]; then
   print_guidlines
else
    if [ "$cmd" = "init" ]; then    
        init $subcmd
    elif [ "$cmd" = "commit" ]; then    
        commit
    elif [ "$cmd" = "create_release" ]; then    
        create_release
    elif [ "$cmd" = "create_feature" ]; then    
        create_feature
    elif [ "$cmd" = "create_hotfix" ]; then            
        create_hotfix
    elif [ "$cmd" = "create_release" ]; then            
        create_release
    elif [ "$cmd" = "version" ]; then            
        get_current_version
        echo "${tmp_v[0]}.${tmp_v[1]}.${tmp_v[2]}"
    # elif [ "$cmd" = "release" ]; then    
    #     create_release    
    else
        print_guidlines
    fi

fi

