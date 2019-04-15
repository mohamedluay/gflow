####### Global Variables
cmd=$1
subcmd=$2
config_file="config.json"

##################### Init Command Begin  ###################

function init {
    if [ -e "$config_file" ]; then
        if [ "$1" = "--f" ]; then
            perform_flow_init
        else
            echo "Workflow Already Initialized, in order to re intialize write"
            tput setaf 1; echo "  - gflow init --f"
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
        tput setaf 1; echo "ERROR:<->Version Number is not valid: '$entered_version'"    
        echo "Version number should be something like 3.2.88'"    
        tput sgr0
        ask_user_version
    fi
}

##################### Init Command End  ###################

##################### Commit Command Begin  ###################

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
        echo "Hi"
    fi
fi
