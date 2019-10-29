#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__gflow_commit__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__gflow_commit__imported=1

function gflow_commit {
  if [ $snapshot_has_changes = true ]; then
    if is_protected_branch ; then
        gflow_log_error "You are commiting on a protected branch"
        select_branch_type || return $FALSE        
    else
        ask_if_to_commit_to_current_branch || return $FALSE
    fi    
    do_commit_changes || return $FALSE
  else
    # ToDo: Add User Name To Log
    gflow_log_warning "You don't have any changes to commit!"
  fi  
}

function select_branch_type {
    gflow_log_highlight "Please select the type of your commit from the options below to CONTINUE 👇"
    options=("1- Hot fix 🔧" "2- New Feature ⚙️" "3- Abort Commit 🛑🚦")
    select_option "${options[@]}"
    choice=$?
    case $choice in
        0) gflow_start_hotfix_flow || return $FALSE;;
        1) gflow_start_feature_flow || return $FALSE;;
        2) return $FALSE;;
    esac
}

function ask_if_to_commit_to_current_branch {
    gflow_log_highlight "You are currently on branch ${current_branch}, do you want to commit these changes to it?"
        options=("1- Yes 👍" "2- No 👎")
        select_option "${options[@]}"
        choice=$?
        case $choice in
            0) return $TRUE;;
            1) select_branch_type || return $FALSE;;            
        esac
}

function do_commit_changes {
    # ToDo: Check If tempchangelog file exists
    vim $temp_changelog_file
    if  does_temp_changelog_exists; then
        is_modified="$(git diff $temp_changelog_file)"
        if [ -z "$is_modified" ]; then
            warn_about_empty_changelog || return $FALSE
        else
            commit_message="$(git diff --color $temp_changelog_file | perl -wlne 'print $1 if /^\e\[32m\+\e\[m\e\[32m(.*)\e\[m$/')"                        
            git add .
            git commit -m "$commit_message" &> /dev/null || return $FALSE
        fi
    else
        warn_about_empty_changelog || return $FALSE
    fi    
}

function warn_about_empty_changelog {    
    gflow_log_error "You have to update the temp changelog in order to commit your work 🚨"
    gflow_log_error "Updated Change log will be used in commit message 💬"
    options=("1- try again ⚙️" "2- Abort Commit 🛑🚦")
    select_option "${options[@]}"    
    choice=$?
    case $choice in
        0) do_commit_changes;;
        1) return $FALSE;;
    esac
}