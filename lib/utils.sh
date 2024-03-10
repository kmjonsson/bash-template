function fn_exists() {
    [[ $(type -t $1) == function ]]
}

function validate_module {
    local mod="$1"
    for f in validate usage module_init generate args; do
        if ! fn_exists "${mod}_${f}" ; then
            echo "module ${mod} is missing ${f}"
            exit 1
        fi
    done
}