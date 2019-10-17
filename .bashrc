# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export GREP_OPTIONS="--color"

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
HISTFILESIZE=10000
export HISTSIZE=10000                   # big big history
export HISTFILESIZE=1000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
# Save and reload the history after each command finishes
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;
esac

function virtualenv_info(){
    # Get Virtual Env
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Strip out the path and just leave the env name
        venv="${VIRTUAL_ENV##*/}"
    else
        # In case you don't have one activated
        venv=''
    fi
    [[ -n "$venv" ]] && echo "(venv:$venv) "
}

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

function gbdr {
    git push origin :$1
}

function om {
    $EDITOR $(git status --short | awk '$1 ~ /^M$/ {print $2}')
}

function ogit {
    $EDITOR $( $1 --short | awk '$1 ~ /^M$/ {print $2}')
}

function db_circle_of_life {
    wipe_dbs && alembic upgrade head && populate_garlic seed $gr/development.ini && populate_garlic fixtures -n $1 $gr/development.ini && alembic downgrade base
}

function fresh_db {
    wipe_dbs && alembic upgrade head && populate_garlic seed $gr/development.ini && populate_garlic fixtures -n $1 $gr/development.ini
}

# merge and deploy
function mad {
    git checkout master && git pull && git merge $1 && git push origin master && git branch -d $1 && git push origin :$1 && cd $gr/playbooks && ./deploy.sh
}

# merge pull request
function mpr {
    git checkout master && git pull && git merge $1 && git push origin master && git branch -d $1 && git push origin :$1
}

pyclean () {
    find . -type f -name "*.py[co]" -delete
    find . -type d -name "__pycache__" -delete
}

alias pjson='python -m json.tool'

# Load in the git branch prompt script.
source ~/.bashrc.d/.git-prompt.sh

function setup_ps1 {
    # \[\e[0;32m\] starts a colored section
    # \[\e[0m\] "closes" a colored section "text reset"
    export PS1="\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;31m\]\h\[\e[0m\] \[\e[1;33m\]\w\[\e[0m\]\[\e[1;32m\]\$(__git_ps1) $(virtualenv_info)\[\e[0m\]\\n\[\e[1;31m\]>\[\e[0m\] ";
    export SUDO_PS1="\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;31m\]\h\[\e[0m\] \[\e[1;33m\]\w\[\e[0m\]\[\e[1;32m\]\$(__git_ps1) $(virtualenv_info)\[\e[0m\]\\n\[\e[1;31m\]ROOT ROOT ROOT ROOT\\n\[\e[1;31m\]>\[\e[0m\] ";
}
setup_ps1

alias renew="sudo ipconfig set en0 BOOTP && sudo ipconfig set en0 DHCP"

# sets python virtualenv and then resets the promopt
function wkon {
    pyenv activate $1 && setup_ps1
}

# Automatically activate Git projects' virtual environments based on the
# directory name of the project. Virtual environment name can be overridden
# by placing a .venv file in the project root with a virtualenv name in it
function workon_cwd {
    # Check that this is a Git repo
    GIT_DIR=`git rev-parse --git-dir 2> /dev/null`
    if [ $? == 0 ]; then
        # Find the repo root and check for virtualenv name override
        GIT_DIR=`\cd $GIT_DIR; pwd`
        PROJECT_ROOT=`dirname "$GIT_DIR"`
        ENV_NAME=`basename "$PROJECT_ROOT"`
        if [ -f "$PROJECT_ROOT/.venv" ]; then
            ENV_NAME=`cat "$PROJECT_ROOT/.venv"`
        fi
        # Activate the environment only if it is not already active
        if [ "$VIRTUAL_ENV" != "$WORKON_HOME/$ENV_NAME" ]; then
            if [ -e "$WORKON_HOME/$ENV_NAME/bin/activate" ]; then
                wkon "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_NAME"
            fi
        fi
    elif [ $CD_VIRTUAL_ENV ]; then
        # We've just left the repo, deactivate the environment
        # Note: this only happens if the virtualenv was activated automatically
        pyenv deactivate && unset CD_VIRTUAL_ENV
    fi
}

# New cd function that does the virtualenv magic
function venv_cd {
    cd "$@" && workon_cwd
}

# after using pyenv virtualenv and adapting workwon_cwd I'this sometimes crashes
#alias cd="venv_cd"

export GIT_EDITOR='emacs';
export EDITOR='emacs';

#xcode
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

#haskell
export PATH="$HOME/Library/Haskell/bin:$PATH"

#clojure
alias clojure_repl="java -cp ~/programming/clojure-1.5.1/clojure-1.5.1.jar clojure.main"

alias pine='alpine'
alias ll='ls -lh'
alias lal='ls -alh'
alias lsa='ls -ah'
alias server="$git/script/server"
alias wget="curl -O"
alias ec2pers="ssh benmathes@ec2-107-22-151-214.compute-1.amazonaws.com -i ~/.ssh/aws/personalserver.pem"
alias ec2persroot="ssh ec2-user@ec2-107-22-151-214.compute-1.amazonaws.com -i ~/.ssh/aws/personalserver.pem"
alias mostfreq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30';
alias sd='sudo';
alias look_busy='perl -le "use Time::HiRes qw( usleep ); while (1) { print \"=\" x int(rand(50)) . rand(100); usleep(rand(int(1000000))); }"';
alias sc='emacs ~/.bashrc && . ~/.bashrc';
alias rf='. ~/.bashrc';
alias e='emacs';
alias tlog='tail -f $git/log/development.log'
alias slow_partials="tlog | egrep '^Rendered.*\d{3,}'"
alias g='hub';
alias h='heroku';
alias gs='gb; git status --short';
alias gb='git branch';
alias gd='git diff';
alias gap='git add -p';
alias gc='git commit --verbose';
alias gp='git pull';
alias gph="git push heroku master";
alias gpo="git push origin";
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
alias goc="emacs `git diff --name-only`"
alias gbh='for k in `git branch|perl -pe s/^..//`;do echo -e `git show --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k|head -n 1`\\t$k;done|sort -r';
alias fupyc='find ./ -name "*.pyc"  -exec rm -f {} \;';
alias gch='git checkout';
alias greb='git pull --rebase origin master';
alias gdp='git diff origin/master master';
alias gdo='git diff origin/$(__git_ps1) $(__git_ps1)';
alias gdm='git diff master $(git rev-parse --abbrev-ref HEAD) --name-only'
alias egdm='cd $grd && e $(gdm) && cd -'
alias gg='git grep';
alias gbdm="git fetch && git merge master origin/master && git branch --merged master | grep -v master | xargs git branch -d"
alias s3cmd='s3cmd -c $GIT/config/.s3cfg';
alias elog='tail -f ~/logs/error.log';
alias alog='tail -f ~/logs/access.log';
alias glmw='gl --author="Ben Mathes" --since="8 days ago"'; # git log me
alias glm='gl --author="Ben Mathes"'; # git log me
alias be="bundle exec";
alias b="bundle";
alias ber="bundle exec rake";
alias nt="nosetests --pdb --pdb-failures";
alias hosts='sudo emacs /etc/hosts && sudo dscacheutil -flushcache';
alias hubb='hub'; # for some reason I keep tying 'hubb'
alias prq='hub pull-request';
alias cs='cht.sh'
function trs { mv $@ ~/.Trash ; }

# "git grep all" -- using multi, ensuring colors and piping to less for longer results: https://github.com/coryfklein/multi
gga() {
    multi --color=always $@ | less -R
}

export android_sdk="/Users/benmathes/programming/frameworks/adt-bundle-mac-x86_64-20131030/sdk"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
. /Users/benmathes/.bashrc.d/git-completion.bash
# completions on aliases, too
__git_complete g _git
__git_complete gch _git_checkout
__git_complete mad _git_checkout
__git_complete mpr _git_checkout
__git_complete gd _git_diff
__git_complete gb _git_branch

if [ "$TERM" = "screen" ]; then
    echo "[ screen is activated ]"
fi

# MARK: greylock ----------------------------------------
#export gri="$HOME/programming/work/greylock/webapps/intel"
#export gr="$HOME/programming/work/greylock/webapps/garlic"
#export grl="$HOME/programming/work/greylock/apps/greylog"
# alias rg='pserve --reload $gr/development.ini'
# alias wipe_dbs='psql < ~/programming/greylock/wipe_garlic_dbs.sql'
# alias gateway='ssh garlic@54.193.20.12 -i $gr/playbooks/garlic-production.pem -A'
# alias pshl='pshell $gr/development.ini'
# alias symbolicate="/Applications/Xcode.app/Contents/SharedFrameworks/DTDeviceKitBase.framework/Versions/A/Resources/symbolicatecrash -v"
# alias mng="$gri/manage.py"
# alias ri='cd $gri && workon intel && parallel --tag ::: "sass --watch $gri/intel/static/css/main.scss:$gri/intel/static/css/bundle.css" "npm start" "mng runserver_plus" && cd -'
# alias intel_celery='rabbitmq-server & mng celeryd'

# clean cache and reinstall from scractch
function pod_clean {
    echo "cleaning cache"
    rm -rf "${HOME}/Library/Caches/CocoaPods"
    rm -rf "`pwd`/Pods/"
    echo "running pod update"
    pod update
}

# MARK: greylock done.

eval $(thefuck --alias)

# add in rabbitMQ
export PATH="$PATH:/usr/local/sbin"

export NVM_DIR="/Users/benmathes/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# THIEL
export BLPAPI_ROOT='/Users/benmathes/programming/work/thiel/blpapi_cpp_3.8.1.1'
export DYLD_LIBRARY_PATH='/Users/benmathes/programming/work/thiel/blpapi_cpp_3.8.1.1/Darwin'
alias tma_db='mycli -u bmathes -pbmathes123 --host 127.0.0.1 --port 33000 -D tmanalytics_dev'
alias tma_db_raw='mysql -u bmathes -pbmathes123 --host 127.0.0.1 --port 33000 -D tmanalytics_dev'
export grd="$HOME/programming/work/thiel/dashboard"
export grdd="$HOME/programming/work/thiel/dashboard/dashboard"
export grtma="$HOME/programming/work/thiel/tmanalytics"
export grtmac="$HOME/programming/work/thiel/tmacore"
export grtmu="$HOME/programming/work/thiel/tmutils"
export grtm="$HOME/programming/work/thiel/tmmodels"
alias mng="python $grd/dashboard/manage.py"
alias mngm="$grtm/manage.py"
alias run_dashboard_watchers='cd $grd/dashboard && wkon dashboard && parallel --tag ::: "yarn run test-watch" "yarn run build-watch" "yarn run eslint" && cd -' # "yarn run eslint-fix"
alias prod="ssh  -i ~/.ssh/id_rsa jenkins@tma.thielmacro.com"
export DATABASE_URL_DEVELOPMENT=postgres://dashboard_dev_user:s3kr1t@localhost:5432/dashboard_dev
export DATABASE_URL_KEY=DATABASE_URL_DEVELOPMENT

# angellist setup
#eval "$(~/programming/work/angellist/docker-host/environment)"
#export VAGRANT_DEFAULT_PROVIDER="vmware_fusion"
export RUN_LOCALLY=1
export al="/Users/benmathes/programming/work/angellist/AngelList"
alias alup="rm -rf $al/.sass-cache && cd $al && brew services start solr && brew services start memcached &&  be make up; brew services stop solr; brew services stop memcached; cd -"
alias aldb="mycli -u root -pangellist --host 127.0.0.1 --port 33000 angellist_development"
alias aldb_raw="mysql -u root -pangellist --host 127.0.0.1 --port 33000 angellist_development"

export PATH="$PATH:$(brew --prefix npm)"

export GOPATH="/Users/benmathes/go/"
export GOBIN="$GOPATH/bin" # shouldn't be needed, but is: https://stackoverflow.com/a/32357023
export PATH="$GOPATH/bin/:$PATH"

# HOMEBREW WINS.
export PATH="/usr/local/bin:$PATH"

# I want homebrew to win all races for $PATH precedence _except_ for python
# virtual environments
export PATH="$WORKON_HOME/${VIRTUAL_ENV##*/}/bin/:$PATH"

# pyenv autocomplete
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

##To use Homebrew's directories rather than ~/.pyenv add to your profile:
#export PYENV_ROOT=/usr/local/opt/pyenv
#export WORKON_HOME=$HOME/.virtualenvs
#export PROJECT_HOME=$HOME/Devel
#export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
#source /usr/local/bin/virtualenvwrapper.sh

# workaround for pycryptodome issues in 3.5
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"

# Tech Equity Collab work
export grtec="$HOME/programming/tech-equity-collabrative/Voter-Info/"

# disable the default virtualenv prompt change
export VIRTUAL_ENV_DISABLE_PROMPT=1

. /Users/benmathes/torch/install/bin/torch-activate
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
alias rni="kill $(lsof -t -i:8081); rm -rf ios/build/; react-native run-ios"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
