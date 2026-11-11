#!/bin/bash
#
# vim-plug and the plugins in vimrc, for vim and nvim. Both editors read the
# same vimrc and share ~/.vim/plugged, so PlugInstall runs once, through nvim
# when present.

set -e

PLUG_URL=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
VIMRC="${DOTFILES_ROOT:-$HOME/.dotfiles}/vim/vimrc.symlink"

have_vim=; have_nvim=
command -v vim >/dev/null 2>&1 && have_vim=1
command -v nvim >/dev/null 2>&1 && have_nvim=1
if [ -z "$have_vim$have_nvim" ]; then
  echo "  vim: neither vim nor nvim is installed"
  exit 1
fi

# plug.vim goes into each editor's autoload dir, or the linked vimrc fails at
# plug#begin on every start.
if [ -n "$have_vim" ]; then
  curl -fsSLo "$HOME/.vim/autoload/plug.vim" --create-dirs "$PLUG_URL"
fi
if [ -n "$have_nvim" ]; then
  curl -fsSLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs "$PLUG_URL"
fi

# Neither editor's exit status says whether the install worked: headless nvim
# exits 0 after any error, and vim -es (silent Ex mode, the only mode that
# cannot stall on a "Press ENTER" prompt) exits 1 on errors that plugin
# autocommands raise in Ex mode. So the editor writes the plugin dirs still
# missing after PlugInstall to a file and the shell checks that. -u starts
# vim in compatible mode; the vimrc's first line undoes it.
missing="$HOME/.vim/.plug-missing.$$"
rm -f "$missing"
verify="call writefile(filter(map(values(g:plugs), 'v:val.dir'), '!isdirectory(v:val)'), '$missing')"
if [ -n "$have_nvim" ]; then
  editor=nvim
  echo "  nvim: installing plugins"
  nvim --headless -u "$VIMRC" -i NONE -c PlugInstall -c "$verify" -c qa || true
else
  editor=vim
  echo "  vim: installing plugins"
  vim -es -u "$VIMRC" -i NONE -c PlugInstall -c "$verify" -c qa || true
fi

if [ ! -f "$missing" ]; then
  echo "  $editor: PlugInstall did not run; see the errors with: $editor -u $VIMRC"
  exit 1
elif [ -s "$missing" ]; then
  echo "  $editor: plugins still missing after PlugInstall:"
  sed 's/^/    /' "$missing"
  rm -f "$missing"
  exit 1
fi
rm -f "$missing"
