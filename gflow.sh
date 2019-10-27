#!/usr/bin/env bash
set -o nounset
global_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. "$global_directory/modules/gflow_logger.sh"
. "$global_directory/modules/gflow_constants.sh"
. "$global_directory/modules/gflow_config.sh"
. "$global_directory/modules/gflow_init.sh"
. "$global_directory/modules/gflow_git.sh"
. "$global_directory/modules/gflow_feature_flow.sh"
. "$global_directory/modules/gflow_changelog.sh"


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

function catch {
    local error="$1"
    gflow_log_error "$error"
    return 1
}

function revert_for_error {
    gflow_log_error "Gflow Had An Error, Reverting Changes!"
    gflow_load_snapshopt
}

cmd="$1"
subcmd="${2-default}"
if [ -z "$cmd" ]; then
     print_guidlines
 else
    if [ "$cmd" = "init" ]; then    
        init "$subcmd"
    elif [ "$cmd" = "commit" ]; then    
        commit
    elif [ "$cmd" = "create_release" ]; then    
        create_release
    elif [ "$cmd" = "create_feature" ]; then    
        gflow_start_feature_flow || revert_for_error
    elif [ "$cmd" = "create_hotfix" ]; then            
        create_hotfix
    elif [ "$cmd" = "version" ]; then            
        get_current_version
        echo "${tmp_v[0]}.${tmp_v[1]}.${tmp_v[2]}"
    # elif [ "$cmd" = "release" ]; then    
    #     create_release    
    elif [ "$cmd" = "gflow_version" ]; then            
        echo "$gflow_version"   
    else
        print_guidlines
    fi
fi
