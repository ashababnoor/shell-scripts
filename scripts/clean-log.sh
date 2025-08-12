function clean-log() {
    if [ $# -eq 0 ]; then
        echo -e "${fatal_prefix} No command provided"
        return 1
    fi

    local command=$1
    shift

    # Checking if any empty arguments are passed
    local args=()
    for arg in "$@"; do
        if [ -n "$arg" ]; then
            args+=("$arg")
        fi
    done

    echo -e "$command_running_message $command ${args[@]}"
    "$command" "${args[@]}" | sed -r "s/\\x1B\\[[0-9;]*[mK]//g"
}

clean-log "$@"
