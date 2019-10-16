#!/usr/bin/env bash
set -o nounset

. "./modules/gflow_logger.sh"

gflow_log_error "Error Message"
gflow_log_warning "Warning Message"
gflow_log_successful "Successful Message"
gflow_log_highlight "Higligh Message"
