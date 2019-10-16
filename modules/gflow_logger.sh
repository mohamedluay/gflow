#!/usr/bin/env bash

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
