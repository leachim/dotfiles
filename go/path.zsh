# Go: keep GOPATH (module cache, installed binaries) out of $HOME
export GOPATH="$HOME/.local/share/go"
export PATH="$GOPATH/bin:$PATH"
