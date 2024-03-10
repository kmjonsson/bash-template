#!/usr/bin/bash

set -e 

source "${BASH_SOURCE%/*}"/lib/utils.sh
source "${BASH_SOURCE%/*}"/lib/template.sh

modules=()
modules+=("demo")   # demo module
modules+=("git")    # git init!

export INIT_TMPDIR=$(mktemp -d)
echo "tmp: $INIT_TMPDIR"

for mod in "${modules[@]}"; do
	source "${BASH_SOURCE%/*}"/modules/$mod.sh
    validate_module "$mod"
    ${mod}_module_init
done

echo -n "" > ${INIT_TMPDIR}/params.sh

function usage {
    echo "$0:"
    for mod in "${modules[@]}"; do
        ${mod}_usage
    done
    echo "  --help"
    echo "      Usage..."
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
        echo "Usage: $(basename $0) [-a] [-b] [-c arg]"
        exit 1
        ;;
    -*|--*)
        found_args=0
        for mod in "${modules[@]}"; do
            res=$(${mod}_args "${@}")
            if [[ "${res}" == "2" ]]; then
                found_args=1
                shift
                shift
            elif [[ "${res}" == "1" ]]; then
                found_args=1
                shift
            elif [[ "${res}" != "0" ]]; then
                echo "Failed to handle args in module ${mod}"
                echo "${res}"
                exit 1
            fi            
        done
        if [[ $found_args -eq 0 ]]; then
            usage
            exit 1
        fi
      ;;
  esac
done

echo "Loading.."
. $INIT_TMPDIR/params.sh

actions=()
invalid=0
for mod in "${modules[@]}"; do
    echo $mod
    if ! ${mod}_validate ; then
        invalid=1
    else
        readarray -t act < <(${mod}_generate)
        rc=$?
        if [[ $rc -ne 0 ]]; then
            echo "Failed to generate $mod"
            exit 1
        fi
        actions+=("${act[@]}")
    fi
done

if [[ "$invalid" -ne 0 ]]; then
    echo "Invalid?"
    exit 1
fi

IFS=$'\n' sorted_actions=($(sort -n <<<"${actions[*]}"|cut -d. -f2-))

for input in "${sorted_actions[@]}"; do
    action="unknown"
    args=""
    if ! [[ $input =~ ^([^:]+):(.*)$ ]] && ! [[ $input =~ ^([^:]+)$ ]]; then
        echo "Bad action..."
        exit 1
    fi
    action="${BASH_REMATCH[1]}"
    args="${BASH_REMATCH[2]}"
    IFS=";" read -r -a arr <<< "${args}"
    if [[ "${action}" == "tmpl" ]]; then
        template_file_to "${arr[@]}"
    elif [[ "${action}" == "cp" ]]; then
        cp -v "${arr[@]}"
    else
        if fn_exists ${action} ; then
            ${action} "${arr[@]}"
        else
            echo "Unknown action ${action}"
            exit 1
        fi
    fi
done
