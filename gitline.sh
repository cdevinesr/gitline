generate_gitline() {
    # Colors
    local FLASHRED RED LRED GREEN YELLOW WHITE RESET
    FLASHRED='\[\e[5;31m\]'
    RED='\[\e[0;31m\]'
    LRED='\[\e[1;31m\]'
    GREEN='\[\e[1;32m\]'
    YELLOW='\[\e[1;33m\]'
    BLUE='\[\e[1;34m\]'
    WHITE='\[\e[1;37m\]'
    RESET='\[\e[0m\]'

    # Statusline creation patterns
    local DETACHED AHEAD BEHIND UNTRACKED_FILES PENDING_CHANGES STAGED_CHANGES REBASE REBASE_CONFLICT CONFLICTS_NOT_RESOLVED REBASE_ACTION UPTODATE DIVERGED ON_BRANCH
    DETACHED="HEAD detached at ([^${IFS}]*)"
    AHEAD="is ahead of '.+' by ([0-9]+) commit"
    BEHIND="is behind '.+' by ([0-9]+) commit"
    UNTRACKED_FILES="Untracked files"
    PENDING_CHANGES="Changes not staged for commit"
    STAGED_CHANGES="Changes to be committed"
    REBASE="rebase in progress; onto ([^${IFS}]*)"
    REBASE_CONFLICT="currently rebasing branch '([^${IFS}]*)' on '([^${IFS}]*)'."
    CONFLICTS_NOT_RESOLVED="fix conflicts and then"
    REBASE_ACTION="(split|edit)t?ing a commit while rebasing branch '([^${IFS}]*)' on '([^${IFS}]*)'."
    UPTODATE="is up[ -]to[ -]date with '.+'"
    DIVERGED="Your branch and '.+' have diverged"
    ON_BRANCH="On branch ([^${IFS}]*)"

    # Internal statusline management
    local git_line gstatus branch num_commits branch_state_sep rebase_action rebase_branch rebase_commit
    git_line=""
    branch_state_sep=0
    gstatus=$(git status 2> /dev/null)

    if [[ $? -eq 0 ]]; then
        if [[ "${gstatus}" =~ ${REBASE} ]]; then
            if [[ "${gstatus}" =~ ${REBASE_CONFLICT} ]]; then
                rebase_branch="${BASH_REMATCH[1]}"
                rebase_commit="${BASH_REMATCH[2]}"

                if [[ "${gstatus}" =~ ${CONFLICTS_NOT_RESOLVED} ]]; then
                    git_line="${RED}rebase${WHITE}:${LRED}conflict${WHITE}:${GREEN}${rebase_branch}${WHITE}:${YELLOW}${rebase_commit}"
                else
                    git_line="${RED}rebase${WHITE}:${BLUE}conflict${WHITE}:${GREEN}${rebase_branch}${WHITE}:${YELLOW}${rebase_commit}"
                fi
            elif [[ "${gstatus}" =~ ${REBASE_ACTION} ]]; then
                rebase_action="${BASH_REMATCH[1]}"
                rebase_branch="${BASH_REMATCH[2]}"
                rebase_commit="${BASH_REMATCH[3]}"
                git_line="${RED}rebase${WHITE}:${BLUE}${rebase_action}${WHITE}:${GREEN}${rebase_branch}${WHITE}:${YELLOW}${rebase_commit}"
            else
                rebase_commit="${BASH_REMATCH[1]}"
                git_line="${RED}rebase${WHITE}:${YELLOW}${rebase_commit}"
            fi
        elif [[ "${gstatus}" =~ ${DETACHED} ]]; then
            git_line="${RED}${BASH_REMATCH[1]}"
        elif [[ "${gstatus}" =~ ${ON_BRANCH} ]]; then
            branch="${GREEN}${BASH_REMATCH[1]}"


            if [[ "${gstatus}" =~ ${UNTRACKED_FILES} ]]; then
                if [ "${branch_state_sep}" -eq 0 ]; then
                    branch_state_sep=1
                    branch+="${WHITE}:"
                fi

                branch+="${BLUE}?"
            fi

            if [[ "${gstatus}" =~ ${STAGED_CHANGES} ]]; then
                if [ "${branch_state_sep}" -eq 0 ]; then
                    branch_state_sep=1
                    branch+="${WHITE}:"
                fi

                branch+="${YELLOW}*"
            fi

            if [[ "${gstatus}" =~ ${PENDING_CHANGES} ]]; then
                if [ "${branch_state_sep}" -eq 0 ]; then
                    branch_state_sep=1
                    branch+="${WHITE}:"
                fi

                branch+="${RED}*"
            fi

            if [[ "${gstatus}" =~ ${DIVERGED} ]]; then
                git_line="${branch}${WHITE}:${FLASHRED}!!!${RESET}"
            else
                if [[ "${gstatus}" =~ ${BEHIND} ]]; then
                    num_commits="-${BASH_REMATCH[1]}"
                elif [[ "${gstatus}" =~ ${AHEAD} ]]; then
                    num_commits="+${BASH_REMATCH[1]}"
                elif [[ ! "${gstatus}" =~ ${UPTODATE} ]]; then
                    num_commits="!"
                fi

                git_line="${branch}"

                if [[ -n "${num_commits}" ]]; then
                    git_line+="${WHITE}:${YELLOW}${num_commits}"
                fi
            fi
        fi
    else
        return 0
    fi

    echo " ${WHITE}(${git_line}${WHITE})"
}
