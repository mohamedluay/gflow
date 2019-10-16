#!/usr/bin/env bash
set -o nounset
global_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Import Gflow Modules
. "$global_directory/modules/gflow_logger.sh"
. "$global_directory/modules/gflow_constants.sh"
. "$global_directory/modules/gflow_graphical_selector.sh"
. "$global_directory/modules/gflow_config.sh"

gflow_log_error "Error Message $gflow_folder_name"
gflow_log_warning "Warning Message"
gflow_log_successful "Successful Message"
gflow_log_highlight "Higligh Message"

gflow_config_get_current_project_version

