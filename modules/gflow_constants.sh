#!/usr/bin/env bash

# avoid double inclusion
if test "${BashInclude__constants__imported+defined}" == "defined"
then
    return 0
fi
BashInclude__constants__imported=1

gflow_folder_name="./.gflow"
config_file="$gflow_folder_name/config.json"
temp_changelog_file="$gflow_folder_name/temp_changelog.md"
gflow_version="1.1.0"