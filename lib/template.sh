#!/usr/bin/bash

set -e 

function p() {
    template "$@"
}

export -f p

function template() {
    local content="${*}"
    failed_file=$(mktemp)
    function _error_trap {
        local error_code=$?
        local error_command=$BASH_COMMAND

        # Log the error details
        echo "Error occurred: $error_command (exit code: $error_code)"  >> $failed_file
        exit 1
    }
    export -f _error_trap
    output=$(trap _error_trap ERR; eval $'set -E; cat <<ASDF\n'"$content"$'\nASDF')
    local error=$(cat $failed_file)
    rm $failed_file
    if [[ ! -z $error ]]; then
        echo "$error"
        return 1
    fi
    echo -n "$output"
    return 0
}

function template_file() {
    local file=$1
    local content
    IFS="" content=$(cat $file)
    rc=$?
    if [[ $rc -gt 0 ]]; then
        echo "Failed to read $file"
        return 1;
    fi
    template "$content"
}

function template_file_to() {
    local file=$1
    local to=$2
    local output
    output="$(template_file $file)"
    rc=$?
    if [[ $rc -eq 0 ]]; then
        echo "$output" > "$to"
    fi
    
    return $rc
}
