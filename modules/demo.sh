

function demo_validate {
    return 0
}

function demo_generate {
    echo "50.tmpl:test.tmpl;output/output.1.txt"
    echo "50.cp:test.tmpl;output/output.1.tmpl"
    echo "50.demo_demo"
}

function demo_demo {
    echo "This is just a demo"
}

function demo_usage {
    echo "  --demo"
    echo "      Demo..."
}

function demo_args {
    case $1 in
        --demo)
            echo "1"
        ;;
        *)
            echo "0"           
        ;;
    esac    
}

function demo_module_init {
    true
}