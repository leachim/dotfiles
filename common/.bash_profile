## Load profile and bashrc for bash login sessions (e.g. via ssh)

if [ -f ~/.profile ]; then
    source ~/.profile
fi

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
