
function _git_url_validate {
    if [[ $1 =~ ^https://github.com/ ]]; then
        return 0
    fi
    return 1
}

function git_validate {
    if [[ "${GIT_URL}" == "" ]]; then
        echo "--git-url is not set"
        return 1
    fi
    if ! _git_url_validate "${GIT_URL}"; then
        echo "--git-url is invalid"
        return 1
    fi
    return 0
}

function git_generate {
    echo "10.git_init"
}

function git_init {
    echo $pwd
    (
        cd output
        git init
        git checkout -b "${GIT_BRANCH:-main}"
        git remote add origin "${GIT_URL}"
    )
    echo $pwd
}

function git_usage {
    echo "  --git-branch 'branch name'"
    echo "      Name of default branch. Default: main"
    echo "  --git-url 'url to git repo'"
    echo "      Url to git repo"
}

function git_args {
    case $1 in
        --git-branch)
            # validate $2
            echo "export GIT_BRANCH=\"$2\"" >> ${INIT_TMPDIR}/params.sh
            echo "export GIT_MODULE_ACTIVE=\"true\"" >> ${INIT_TMPDIR}/params.sh
            echo "2"
        ;;
        --git-url)
            if ! _git_url_validate "${2}"; then
                echo "--git-url is invalid"
                return
            fi
            echo "export GIT_URL=\"$2\"" >> ${INIT_TMPDIR}/params.sh
            echo "export GIT_MODULE_ACTIVE=\"true\"" >> ${INIT_TMPDIR}/params.sh
            echo "2"
        ;;
        *)
            echo "0"           
        ;;
    esac    
}

function git_module_init {
    true
}