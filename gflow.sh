#!/usr/bin/env bash
set -o nounset
global_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. "$global_directory/modules/gflow_logger.sh"
. "$global_directory/modules/gflow_graphical_selector.sh"
. "$global_directory/modules/gflow_constants.sh"
. "$global_directory/modules/gflow_config.sh"
. "$global_directory/modules/gflow_init.sh"
. "$global_directory/modules/gflow_git.sh"
. "$global_directory/modules/gflow_feature_flow.sh"
. "$global_directory/modules/gflow_changelog.sh"
. "$global_directory/modules/gflow_commit.sh"
. "$global_directory/modules/gflow_hotfix_flow.sh"
. "$global_directory/modules/gflow_release_flow.sh"

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
    gflow_log_highlight "Gflow Is Currently Runing On Version $gflow_version"
}

function revert_for_error {
    gflow_log_error "Gflow Had An Error, Reverting Changes!"
    gflow_load_snapshopt
}

readonly TRUE=0
readonly FALSE=1

cmd="${1-guide}"
subcmd="${2-default}"
if [ -z "$cmd" ]; then
     print_guidlines
 else
    if [ "$cmd" = "init" ]; then    
        init "$subcmd"
    elif [ "$cmd" = "commit" ]; then    
        gflow_commit || revert_for_error
    elif [ "$cmd" = "create_release" ]; then    
        gflow_start_release_flow || revert_for_error
    elif [ "$cmd" = "create_feature" ]; then    
        gflow_start_feature_flow || revert_for_error
    elif [ "$cmd" = "create_hotfix" ]; then            
        gflow_start_hotfix_flow || revert_for_error
    elif [ "$cmd" = "version" ]; then            
        gflow_config_read_current_project_version
        gflow_log_successful "$current_project_version_text"
    elif [ "$cmd" = "gflow_version" ]; then            
        echo "$gflow_version"   
    else
        print_guidlines
    fi
fi
