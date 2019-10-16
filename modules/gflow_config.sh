#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__gflow_config__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__gflow_config__imported=1

function gflow_config_get_current_project_version {
    current_project_version=$(sed -n 's/.*"version": "\([^"]*\)"/\1/p' "$config_file")
    current_project_version=( "${current_project_version//./ }" ) 
}

function gflow_config_pump_project_version {
    local version="$1"
     echo "
    {
        \"version\": \"$version\"
    }
    " > "$config_file"
}

function create_cli_directory {
    mkdir "$gflow_folder_name"
}

function create_file {
    local file_name="$1"
    touch "$file_name"
}
