# gitline
Git status information on your Bash shell prompt.

## Instructions for Use
1. Place `gitline.sh` in your preferred location (example suggests your home directory).
2. Modify your `.bashrc` to include something like this:

```bash
source ~/gitline.sh

build_ps1() {
    local git_line=$(generate_gitline)
    export PS1="\[\e[1;36m\]\u@\h \[\e[1;31m\]\w${git_line}\[\e[1;36m\]\$\[\e[0m\] "
}

export PROMPT_COMMAND="build_ps1"
```
