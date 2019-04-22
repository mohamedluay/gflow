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
    tmp_v=$(sed -n 's/.*"version": "\([^"]*\)"/\1/p' config.json)
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
            load_stashed 
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
        0) commit_code;;
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
-

### Changed
-

### Removed
-

### Deprecated
- 

### Fixed
-
### Security
-         
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
    git checkout $current_branch
    load_stashed    
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
    ## Commit & push init
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

function stash_changes {
    git add .
    git stash
}

function load_stashed {
    git stash pop
}
##################### Init Command End  ###################

##################### Commit Command Begin  ###################

function commit {
    # Check if directory is clean 
    if [ -z "$(git status --porcelain)" ]; then 
        echo "$(git status)"
    else 
        current_branch="$(git symbolic-ref --short -q HEAD)"
        is_protected_branch
    fi
}

function is_protected_branch {
    if [ "$current_branch"="master" ] || [ "$current_branch"="develop" ]; then
        show_wrong_branch_warning        
        ask_for_commit_type
    else
        echo "Nah"
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
    options=("1- Hot fix 🔧" "2- New Feature ⚙️" "3- New Release 🏗")
    select_option "${options[@]}"
    choice=$?
    case $choice in
        0) checkout_and_commit_hotfix;;
        1) checkout_and_commit_feature;;
        2) checkout_and_commit_release;;
    esac
}

function checkout_and_commit_hotfix {
    stash_changes
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
    commit_code
}

function checkout_and_commit_feature {
    echo "Feature"
}

function checkout_and_commit_release {
    echo "release"
}   

##################### Commit Command End  ###################
cmd=$1
subcmd=$2
if [ -z "$cmd" ]; then
    echo "
Wrong command, these are the commands supported so far
        - init       Init the Project's Workflow
        - commit     Do a Commit flow
        - merge      Do a merge request flow to develop
        - release    Release A version 
        - help       Help comand
    "
else
    if [ "$cmd" = "init" ]; then    
        init $subcmd
    elif [ "$cmd" = "commit" ]; then    
        commit
    fi
fi
