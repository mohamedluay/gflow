#!/usr/bin/env bash

GLOBAL_FILE_PATH=/usr/local/bin/
FILE_NAME=gflow

USER_COMMAND=$1
USER_SUB_COMMAND=$2
NEW_GFLOW_VERSION=$(./gflow.sh gflow_version)

function install {
    git pull origin master 
    cp "${FILE_NAME}.sh" "${GLOBAL_FILE_PATH}"
    mv "${GLOBAL_FILE_PATH}${FILE_NAME}.sh" "${GLOBAL_FILE_PATH}${FILE_NAME}"
    chmod u+x "${GLOBAL_FILE_PATH}${FILE_NAME}"
}

function uninstall {
    rm "${GLOBAL_FILE_PATH}${FILE_NAME}"
}

function update {
    uninstall
    install
}

function check_if_gflow_installed {
    if [ -f "${GLOBAL_FILE_PATH}${FILE_NAME}" ]; then
        IS_GFLOW_INSTALLED=1
        CURRENT_GFLOW_VERSION=$(gflow gflow_version)
    else
        IS_GFLOW_INSTALLED=0
    fi
}

check_if_gflow_installed

if [ -z "$USER_COMMAND" ]; then
   echo "
        - install        Install gflow script globally on your system
        - update         Update this script globally on your system
        - uninstall      Uninstall gflow script globally on your system
   "
else
    if [ "$USER_COMMAND" = "install" ]; then 
        if [ "$IS_GFLOW_INSTALLED" = 1 ]; then
            echo "gflow is already installed on this device, use './gflow.sh update' if you want to update it"
        else
            echo "Installing Version *********** "  
            ./gflow.sh gflow_version  
            install > /dev/null 2>&1
            echo "Installation Complete *********** "
        fi            
    elif [ "$USER_COMMAND" = "update" ]; then 
        if [ "$IS_GFLOW_INSTALLED" = 1 ]; then

            echo "Updateing from Version $CURRENT_GFLOW_VERSION To Version $NEW_GFLOW_VERSION" 
            update > /dev/null 2>&1
            echo "Update Complete *********** "  
        else
            echo "gflow is not installed on this device, use './gflow.sh install' in order to install it."
        fi         
    elif [ "$USER_COMMAND" = "uninstall" ]; then  
        if [ "$IS_GFLOW_INSTALLED" = 1 ]; then
            echo "Removing Version $CURRENT_GFLOW_VERSION From Device!!"  
            uninstall > /dev/null 2>&1
            echo "Gflow has been removed from your device"  
        else
            echo "gflow is not installed on this device, use './gflow.sh install' in order to install it."
        fi  
    else
        echo "
        - install        Install gflow script globally on your system
        - update         Update this script globally on your system
        - uninstall      Uninstall gflow script globally on your system
        "        
    fi

fi

