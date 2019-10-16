#!/usr/bin/env bash
set -o nounset

#### Import Gflow Modules
. "./modules/gflow_logger.sh"
. "./modules/gflow_constants.sh"

gflow_log_error "Error Message $gflow_folder_name"
gflow_log_warning "Warning Message"
gflow_log_successful "Successful Message"
gflow_log_highlight "Higligh Message"
