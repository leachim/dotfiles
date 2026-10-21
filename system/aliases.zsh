# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if command -v gls &>/dev/null
then
  alias ls="command gls -F --color"
  alias l="command gls -lAh --color"
  alias ll="command gls -l --color"
  alias la='command gls -A --color'
fi

# Use python3 as python if python is not available
if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
  alias python="python3"
fi