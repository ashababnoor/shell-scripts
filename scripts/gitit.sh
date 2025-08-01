#!/bin/sh

SCRIPT_DIR=$(cd "$(dirname -- "$0")"; pwd)
source $SCRIPT_DIR/colors.sh


command_running_message="${color_cyan}Running command:${style_reset}"
info_prefix="${color_dodger_blue_bold}INFO:${style_reset}"
warning_prefix="${color_yellow_bold}WARNING:${style_reset}"
error_prefix="${color_red_bold}ERROR:${style_reset}"
fatal_prefix="${color_red_bold}FATAL:${style_reset}"


function check_command_installed() {
    if [ $# -eq 0 ]; then
        echo -e "${fatal_prefix} No command provided"
        return 1
    fi

    if [ -z "$1" ]; then
        echo -e "${fatal_prefix} Empty command provided"
        return 1
    fi

    if [ $# -gt 1 ]; then
        echo -e "${fatal_prefix} Too many arguments provided"
        return 1
    fi

    local command=$1
    if ! command -v $command &> /dev/null; then
        return 1
    else
        return 0
    fi
}

function execute() {
    if [ $# -eq 0 ]; then
        echo -e "${fatal_prefix} No command provided"
        return 1
    fi

    local command=$1
    shift

    if ! command -v "$command" &> /dev/null; then
        echo -e "${fatal_prefix} Command '$command' not found"
        return 1
    fi

    # Checking if any empty arguments are passed
    local args=()
    for arg in "$@"; do
        if [ -n "$arg" ]; then
            args+=("$arg")
        fi
    done

    echo -e "$command_running_message $command ${args[@]}"
    "$command" "${args[@]}"
}


# Array to hold all dependencies
dependencies=("git" "awk" "sed" "grep")

# Function to check if dependencies are installed
function check_dependencies() {
    for dependency in "${dependencies[@]}"; do
        check_command_installed "$dependency"
        if [[ $? -ne 0 ]]; then
            echo -e "${fatal_prefix} $dependency is not installed"
            echo "$dependency must be installed to use gitit"
            return 1
        fi
    done
}

# Call the function and check its return status
if ! check_dependencies; then
    echo ""
    echo "Dependency check failed, skipping gitit installation"
    return
fi


gitit_name_ascii_art="""${style_bold}
           d8b  888     d8b  888    
           Y8P  888     Y8P  888    
                888          888    
  .d88b.   888  888888  888  888888 
 d88P'88b  888  888     888  888    
 888  888  888  888     888  888    
 Y88b 888  888  Y88b.   888  Y88b.  
  'Y88888  888   'Y88b  888   'Y88b 
      888                       
 Y8b d88P                       
  'Y88P'                        
${style_reset}"""

gitit_help_message="""\
$gitit_name_ascii_art

Git add, commit and push in one command

${style_bold}Usage${style_reset} 
    gitit [OPTIONS] <commit-message>

${style_bold}Options${style_reset} 
    -s, --skip-stage  Do not add changes to staging area
    -f, --force       Force push the branch to remote
    -h, --help        Display this help message

${style_bold}Example${style_reset}
    gitit \"my awesome commit\"
    gitit --skip-stage \"commit without adding changes to stage\"
    gitit --force \"force push commit\"
"""

gitit_help_hint_message="Run 'gitit --help' to display help message"

remote="origin"


function check_if_valid_git_repo(){
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [ -d "$dir/.git" ]; then
            echo "This is a Git repository."
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "This is not a Git repository."
    return 1
}

function get_git_remote_url(){
    remote_url=$(git remote get-url "$remote")
    echo $remote_url
}

function get_git_remote_server() {
    local remote_url=$(get_git_remote_url)

    # Handle different URL formats
    if [[ $remote_url == *"@"* ]]; then
        # SSH format: git@github.com:username/repo.git or ssh://git@github.com/username/repo.git
        if [[ $remote_url == ssh://* ]]; then
            # SSH protocol format: ssh://git@github.com/username/repo.git
            local remote_server=$(echo $remote_url | awk -F/ '{print $3}' | awk -F@ '{print $2}')
        else
            # Standard SSH format: git@github.com:username/repo.git
            local remote_server=$(echo $remote_url | awk -F: '{print $1}' | awk -F@ '{print $2}')
        fi
        echo $remote_server
    elif [[ $remote_url == https://* || $remote_url == http://* ]]; then
        # HTTPS/HTTP format: https://github.com/username/repo.git
        local remote_server=$(echo $remote_url | awk -F/ '{print $3}')
        echo $remote_server
    elif [[ $remote_url == git://* ]]; then
        # Git protocol: git://github.com/username/repo.git
        local remote_server=$(echo $remote_url | awk -F/ '{print $3}')
        echo $remote_server
    elif [[ $remote_url == file://* ]]; then
        # Local file path: file:///path/to/repo.git
        echo "local-repository"
    else
        # Relative or other format, assume local
        echo "local-repository"
    fi
}

function get_git_remote_repository(){
    local remote_url=$(get_git_remote_url)

    # Handle different URL formats
    if [[ $remote_url == *"@"* ]]; then
        if [[ $remote_url == ssh://* ]]; then
            # SSH protocol format: ssh://git@github.com/username/repo.git
            local username=$(echo $remote_url | awk -F/ '{print $4}')
            local repo=$(echo $remote_url | awk -F/ '{print $5}' | sed 's/.git$//')
            echo "$username/$repo"
        else
            # Standard SSH format: git@github.com:username/repo.git
            local remote_repository=$(echo $remote_url | awk -F: '{print $2}' | sed 's/.git$//')
            echo $remote_repository
        fi
    elif [[ $remote_url == https://* || $remote_url == http://* ]]; then
        # HTTPS/HTTP format: https://github.com/username/repo.git
        local username=$(echo $remote_url | awk -F/ '{print $4}')
        local repo=$(echo $remote_url | awk -F/ '{print $5}' | sed 's/.git$//')
        echo "$username/$repo"
    elif [[ $remote_url == git://* ]]; then
        # Git protocol: git://github.com/username/repo.git
        local username=$(echo $remote_url | awk -F/ '{print $4}')
        local repo=$(echo $remote_url | awk -F/ '{print $5}' | sed 's/.git$//')
        echo "$username/$repo"
    elif [[ $remote_url == file://* ]]; then
        # Local file path: file:///path/to/repo.git
        local path=$(echo $remote_url | sed 's|file:///||' | sed 's|.git$||')
        local repo=$(basename "$path")
        echo "$repo"
    else
        # Relative or other format, use basename
        local path=$(echo $remote_url | sed 's|.git$||')
        local repo=$(basename "$path")
        echo "$repo"
    fi
}

function get_git_current_branch(){
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo $current_branch
}

function print_last_commit_changes() {
    local highlight_color=${1-$color_light_sea_green_bold}

    # Find the commit range of the last push
    local last_commit_hash=$(git log -n 1 --pretty=format:%H)
    local last_commit_short_hash=$(git rev-parse --short $last_commit_hash)
    local last_commit_time=$(git log -n 1 --format="%cd" --date=format:'%a %d %b %Y %H:%M:%S %z')

    # Show modified files in the last commit
    echo "Changes made in last commit: ${highlight_color}$last_commit_short_hash${style_reset} ($last_commit_time)"
    git diff --name-status $last_commit_hash^..$last_commit_hash | awk '
        BEGIN {
            color_D = "\033[0;31m";  # Red
            color_A = "\033[0;32m";  # Green
            color_M = "\033[0;33m";  # Yellow
            color_fbk = "\033[0;36m" # Cyan; Fallback color
            style_reset = "\033[0m"; # Reset color
        }
        {
                 if ($1 == "A") { print color_A $1 style_reset "    " $2 }
            else if ($1 == "M") { print color_M $1 style_reset "    " $2 }
            else if ($1 == "D") { print color_D $1 style_reset "    " $2 }
            else { print color_fbk $1 style_reset "    " $2 }
        }
    '
}

function print_last_commit_message() {
    local highlight_color=${1-$color_light_sea_green_bold}

    local last_commit_hash=$(git log -n 1 --pretty=format:%H)
    local last_commit_short_hash=$(git rev-parse --short $last_commit_hash)
    local last_commit_time=$(git log -n 1 --format="%cd" --date=format:'%a %d %b %Y %H:%M:%S %z')

    # Get the last commit message
    local last_commit_message=$(git log -n 1 --pretty=format:%s)

    echo "Last commit message: ${highlight_color}$last_commit_short_hash${style_reset} ($last_commit_time)"
    echo "${emoji_page_with_curl}   ${last_commit_message}"
}

function do_git_push() {
    local default_push_branch=$(get_git_current_branch)
    local force_push=false
    local branch=""
    local print_success_message=false
    local print_changes_message=false
    local print_last_commit_msg=false
    local highlight_color=$color_dark_orange
    local bypass_check=false


    # Parsing positional arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)
                force_push=true
                shift
                ;;
            --print-success)
                print_success_message=true
                shift
                ;;
            --print-changes)
                print_changes_message=true
                shift
                ;;
             --print-last-commit-msg)
                print_last_commit_msg=true
                shift
                ;;
            *)
                branch="$1"
                shift
                ;;
        esac
    done
    
    local branch=${branch:-$default_push_branch}

    # Check if any remote exists
    if [[ -z $(git remote) ]]; then
        echo -e "No remote repository found"
        echo ""
        echo -e "${warning_prefix} Skipping git push"
        return 1
    fi

    # Check if no upstream is configured for the current branch; if not then empty branch is always pushed
    if ! git rev-parse --abbrev-ref --symbolic-full-name @{upstream} > /dev/null 2>&1; then
        
        # Sometimes above condition can give wrong output as upstream may not actually be set
        # Checking if branch is found in the remote repository
        local branch_in_remote=$(git ls-remote --heads "$remote" | grep refs/heads/"$branch")

        if [[ -z $branch_in_remote ]]; then
            echo -e "${info_prefix} no upstream configured for the current branch"
            echo "New branch will be pushed to remote repository"
            echo ""

            bypass_check=true
        fi
    fi


    # Check if there is anything to push
    local git_status=$(git status --porcelain)

    # Check if there are any changes staged for commit
    # 0 = nothing staged for commit, 1 = changes staged for commit
    git diff --cached --quiet
    local changes_staged=$?

    # Check if there were any commits since the last push
    # Returns commit count
    local commits_since_last_push=0
    [[ $bypass_check == false ]] && commits_since_last_push=$(git rev-list --count "$remote"/"$branch"..)

    # Control flow for checking before performing git push:
    # 
    # If git_status is empty:
    #   - If commit_count is 0: No changes made. Everything is up-to-date.
    #   - If commit_count is greater than 0: Changes have been committed. Need to push.
    # 
    # If git_status is not empty:
    #   - If commit_count is 0:
    #     - If changes_staged is 0: No changes staged to be committed.
    #     - If changes_staged is 1: Changes staged to be committed. Need to commit.
    #   - If commit_count is greater than 0:
    #     - If changes_staged is 0: More changes exist. Additional changes are not staged to be committed. Need to push regardless.
    #     - If changes_staged is 1: More changes exist. Additional changes staged to be committed, need to commit. Need to push regardless.

    if [[ -z $git_status ]]; then
        if [[ $commits_since_last_push -eq 0 && $bypass_check == false ]]; then
            # default push branch is the same as current git branch
            echo -e "On branch: ${highlight_color}${default_push_branch}${style_reset}"
            echo "No changes made. Working tree is clean"
            echo ""
            echo -e "${warning_prefix} Skipping git push"
            
            return 1
        fi
    else
        if [[ $commits_since_last_push -eq 0 && $bypass_check == false ]]; then
            echo -e "On branch: ${highlight_color}${default_push_branch}${style_reset}"
            
            if [[ $changes_staged -eq 0 ]]; then
                echo "Changes not staged for commit. No changes added to commit either"
            else
                echo "Changes staged for commit. But no changes added to commit"
            fi
            
            echo ""
            echo -e "${warning_prefix} Skipping git push"
            
            return 1
        elif [[ $commits_since_last_push -gt 0 ]]; then
            echo -e "On branch: ${highlight_color}${default_push_branch}${style_reset}"
            echo ""
            echo -e "${info_prefix} More changes found in working tree"
            echo "To push additional changes, add changes to stage, commit and then push"
            echo ""
        fi
    fi

    local set_upstream=""
    local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [[ $default_push_branch == $branch && -z $upstream ]]; then
        set_upstream="--set-upstream"
    fi

    local do_force_push=""
    if [[ $force_push == true ]]; then
        do_force_push="--force"
    fi
    
    # Perform git push with the given arguments
    execute git push "$set_upstream" "$do_force_push" "$remote" "$branch"

    # Check if git push was successful
    local push_success=$?
    if [[ $push_success -ne 0 ]]; then
        echo ""
        echo -e "${error_prefix} Git push failed"
        return 1
    fi

    if [[ $print_success_message == true ]]; then
        local server=$(get_git_remote_server)
        local repo=$(get_git_remote_repository)

        # Print push success message
        echo ""
        print_push_success_message "$server" "$repo" "$branch"
    fi

    if [[ $print_last_commit_msg == true ]]; then
        # Print last commit message
        echo ""
        print_last_commit_message
    fi

    if [[ $print_changes_message == true ]]; then
        # Print last commit changes
        echo ""
        print_last_commit_changes
    fi
}

function do_git_pull() {
    local default_pull_branch=$(get_git_current_branch)
    
    local branch=${1:-$default_pull_branch}
    execute git pull "$remote" "$branch"
}

function print_commit_success_message() {
    local branch=$1
    local highlight_color=${2:-$color_dark_orange}

    echo "${color_green_bold}Hurray!${style_reset} ${emoji_party_popper}${emoji_confetti_ball}"
    echo "Successfully, committed changes in branch: ${highlight_color}$branch${style_reset}"
}

function print_push_success_message() {
    local server=$1
    local repo=$2
    local branch=$3
    local highlight_color=${4:-$color_dark_orange}

    echo "${color_green_bold}Hurray!${style_reset} ${emoji_party_popper}${emoji_confetti_ball}"
    echo "Successfully, pushed to remote server: ${highlight_color}$server${style_reset}"
    echo "                        remote repo:   ${highlight_color}$repo${style_reset}"
    echo "                        remote branch: ${highlight_color}$branch${style_reset}"
}

function git_add_commit_push() {
    local skip_stage=false
    local force_push=false
    local commit_message=""
    local branch=""
    local server=""
    local repo=""
    local git_repo_validity_message=""

    # Check if at least one argument is passed
    if [[ $# -lt 1 ]]; then
        echo -e $gitit_help_message
        return 0
    fi

    # Process the arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-stage|-s)
                skip_stage=true
                shift
                ;;
            --force|-f)
                force_push=true
                shift
                ;;
            --help|-h)
                echo -e $gitit_help_message
                return 0
                ;;
            *)
                commit_message="$1"
                shift
                ;;
        esac
    done

    # Check if inside a git repo or not
    git_repo_validity_message=$(git rev-parse --is-inside-work-tree 2>&1)

    if [[ $git_repo_validity_message != "true" ]]; then
        echo -e "${fatal_prefix} $git_repo_validity_message"
        echo ""
        echo "Must be inside a valid git repository to use gitit"
        echo "$gitit_help_hint_message"
        return 1
    fi

    # Check if a commit message is provided
    if [[ -z $commit_message ]]; then
        echo -e "${error_prefix} Please provide a commit message"
        echo ""
        echo "$gitit_help_hint_message"
        return 1
    fi

    # Add changes to staging area if --no-add flag is not given
    if [[ ! $skip_stage == true ]]; then
        execute git add .
    fi

    # Commit changes with the provided message
    execute git commit -m "$commit_message"

    # Check if commit was successful
    if [ $? -ne 0 ]; then
        echo "${error_prefix} Commit failed, not pushing changes"
        return 1
    fi

    # Push changes to the current branch
    branch=$(get_git_current_branch)

    # Check if any remote exists
    if [[ -z $(git remote) ]]; then
        echo -e "${warning_prefix} No remote repository found. Skipping git push"

        # Print commit success message
        echo ""
        print_commit_success_message "$branch"
    else
        if $force_push; then 
            do_git_push --force --print-success "$branch"
        else
            do_git_push --print-success "$branch"
        fi
    fi

    # Print last commit changes
    echo ""
    print_last_commit_changes
}


alias gitit=git_add_commit_push
alias gpush="do_git_push --print-success --print-changes --print-last-commit-msg"
alias gpull=do_git_pull
