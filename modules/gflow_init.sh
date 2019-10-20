#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__gflow_init__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__gflow_init__imported=1


function init {
    if [ -e "$config_file" ]; then
        if [ "$1" = "--f" ]; then
            perform_flow_init
        else
            echo "Workflow Already Initialized, in order to re intialize write"
            gflow_log_highlight "- gflow init --f"
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
  local _version="${1-default}"
    if [ "$_version" = "default" ]; then
        version=0.1.0
    else
        version="$_version"
    fi    
    create_cli_directory
    create_file "$config_file"
    gflow_config_pump_project_version $version    
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