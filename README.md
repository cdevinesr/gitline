# gitline
Git status information on your Bash shell prompt.

## Instructions for Use
1. Place `gitline.sh` in your preferred location (example suggests your home directory).
2. Modify your `.bashrc` to include something like this:

```bash
source ~/gitline.sh

build_ps1() {
    #Use if statement when using "venv" module in python for virtual environment
    local V_ENV=""

    if [ ! -z ${VIRTUAL_ENV} ];then
        V_ENV="($(basename ${VIRTUAL_ENV})) "
    fi

    local git_line=$(generate_gitline)
    export PS1="${V_ENV}\[\e[1;36m\]\u@\h \[\e[1;31m\]\w${git_line}\[\e[1;36m\]\$\[\e[0m\] "
}

export PROMPT_COMMAND="build_ps1"
```
