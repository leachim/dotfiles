# Shared by script/bootstrap, script/install, script/link and script/update.
# Source it after cd-ing to the repo root.

DOTFILES_ROOT="$(pwd -P)"

# One backup directory per run; the per-tool installers read it too.
: "${DOTFILES_BACKUP_DIR:=$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)}"
export DOTFILES_BACKUP_DIR

info ()    { printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"; }
user ()    { printf "\r  [ \033[0;33m??\033[0m ] %s\n" "$1"; }
success () { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
skip ()    { printf "\r\033[2K  [ \033[00;33m--\033[0m ] %s\n" "$1"; }
fail ()    { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n\n" "$1"; exit 1; }

# Link src to dst. Anything already at dst that is not that link is moved to
# $DOTFILES_BACKUP_DIR first.
link_file () {
  local src=$1 dst=$2
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$DOTFILES_BACKUP_DIR"
    mv "$dst" "$DOTFILES_BACKUP_DIR/$(basename "$dst")"
    success "backed up $dst to $DOTFILES_BACKUP_DIR"
  fi
  ln -s "$src" "$dst"
  success "linked $src to $dst"
}

# Every <topic>/<name>.symlink becomes ~/.<name>.
link_dotfiles () {
  local src
  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*'); do
    link_file "$src" "$HOME/.$(basename "${src%.*}")"
  done
  if [ -d "$DOTFILES_BACKUP_DIR" ]; then
    info "replaced files backed up to $DOTFILES_BACKUP_DIR"
  fi
}

# Run an installer under its own shebang; bash if the exec bit was lost.
run_installer () {
  if [ -x "$1" ]; then "$1"; else bash "$1"; fi
}
