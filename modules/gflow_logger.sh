#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__logger__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__logger__imported=1

function gflow_log_error {
    local text_to_log="$1"
    tput setaf 1; 
    echo "$text_to_log"
    tput sgr0;
}

function gflow_log_warning {
    local text_to_log="$1"
    tput setaf 3; 
    echo "$text_to_log"
    tput sgr0;
}

function gflow_log_successful {
    local text_to_log="$1"
    tput setaf 2; 
    echo "$text_to_log"
    tput sgr0;
}

function gflow_log_highlight {
    local text_to_log="$1"
    tput setaf 5; 
    echo "$text_to_log"
    tput sgr0;
}
