# sup yarn
# https://yarnpkg.com
#
# Yarn v1's default global bin dir. Not `yarn global bin`: that starts node on
# every shell.

[[ -d $HOME/.yarn/bin ]] && path+=($HOME/.yarn/bin)
