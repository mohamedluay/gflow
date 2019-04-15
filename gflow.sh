##################### Global Variables & Function  ###################
cmd=$1
subcmd=$2
config_file="config.json"

function warning_color {
    tput setaf 1; 
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
    tmp_v=1.1.2    
    return 1.1.2
}

##################### Init Command Begin  ###################

function init {
    if [ -e "$config_file" ]; then
        if [ "$1" = "--f" ]; then
            perform_flow_init
        else
            echo "Workflow Already Initialized, in order to re intialize write"
            warning_color
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
    echo "
    {
        \"version\": \"$version\"
    }
    " > $config_file
    echo "Gflow Config File Intialized with version ($version)"
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
        warning_color
        echo "ERROR:<->Version Number is not valid: '$entered_version'"    
        echo "Version number should be something like 3.2.88'"    
        ordinary_color        
        ask_user_version
    fi
}

##################### Init Command End  ###################

##################### Commit Command Begin  ###################

function commit {
    current_branch="$(git symbolic-ref --short -q HEAD)"
    echo "$current_branch"
    is_protected_branch
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
    warning_color
    echo "$current_branch branch is a protected branch; you can't commit to it!!!"
    echo "For more info about the gitflow used, check the link below 👇"
    ordinary_color
    echo "https://nvie.com/posts/a-successful-git-branching-model/"
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
    git add .
    git stash
    git checkout master
    old_v=get_current_version        
    ## increment version number
    new_v="2.2.2"
    hotfix_branch_name="hotfix-$new_v"
    git checkout -b $hotfix_branch_name
    ## pump version 
    git add .
    git commit -m"
    Pump Version from $old_v to $new_v
    "    
    git stash pop
    git add .
    ## change log message
    ## git commit message
}

function checkout_and_commit_feature {
    echo "Feature"
}

function checkout_and_commit_release {
    echo "release"
}   

##################### Commit Command End  ###################
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
