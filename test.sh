#!/usr/bin/env bash
set -o nounset

#### Import Gflow Modules
. "./modules/gflow_logger.sh"
. "./modules/gflow_constants.sh"
. "./modules/gflow_graphical_selector.sh"

gflow_log_error "Error Message $gflow_folder_name"
gflow_log_warning "Warning Message"
gflow_log_successful "Successful Message"
gflow_log_highlight "Higligh Message"

options=("1- try again ⚙️" "2- Abort Commit 🛑🚦")
    select_option "${options[@]}"    
    choice=$?
    case $choice in
        0) echo "hi";;
        1) echo "hi ";;
    esac
