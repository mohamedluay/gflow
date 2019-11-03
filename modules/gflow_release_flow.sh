#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__gflow__release_flow__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__gflow__release_flow__imported=1

function gflow_start_release_flow {
  gflow_stash_changes &> /dev/null
  switch_to_release_branch || return $FALSE
  gflow_create_changelog &> /dev/null || return $FALSE
  gflow_load_if_stashed &> /dev/null
}

function switch_to_release_branch {
  ## ToDo: Cherry Pick Flow For Release Branch
  gflow_switch_to_branch "develop" &> /dev/null || return $FALSE
  ask_for_release_branch_name
  local release_branch_name="$__"
  ## Todo: check if there is a branch with the same name exists
  gflow_create_branch $release_branch_name &> /dev/null || return $FALSE
  gflow_log_successful "created & switched to branch $release_branch_name"
}

function ask_for_release_branch_name {
  gflow_config_read_current_project_version
  local tmp_v=("${current_project_version_array[@]}")
  gflow_log_highlight "The current version of the master branch is ${tmp_v[0]}.${tmp_v[1]}.${tmp_v[2]}, which one you want to assign to the new release?!"
  version_option_1="$((tmp_v[0] + 1)).0.0"
  version_option_2="${tmp_v[0]}.$((tmp_v[1] + 1)).0"
  version_option_3="${tmp_v[0]}.${tmp_v[1]}.$((tmp_v[2] + 1))"
  options=("$version_option_1" "$version_option_2" "$version_option_3")
  select_option "${options[@]}"
  choice=$?
  __="'release-${options[$choice]}'"
  # echo "release-${options[$choice]}"
}