#!/bin/bash
# Config for Euler cluster nodes (matches eu-*)

alias quota_euler="cat /cluster/work/bewi/.bewi_user_data_usage.txt"
alias clusterquota='lfs quota -h -g fmlab'

# Cluster-specific paths
export PATH="$HOME/.local/bin:$PATH"
export PATH=$HOME/cuda/bin:$HOME/.claude/local:$HOME/mmseqs2/bin:$PATH
export PATH="$HOME/.pixi/bin:$PATH"
export PATH="/cluster/work/bewi/members/michaes/npm-global/v22.14.0/bin:$PATH"
export LD_LIBRARY_PATH=$HOME/cuda/lib64:$LD_LIBRARY_PATH
export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0"
export XDG_CONFIG_HOME="$HOME/.config"

# Fast Bash defaults on Euler hosts (eu-*). Opt out with:
#   export DOTFILES_CLUSTER_FAST_MODE=0
if [ -n "$BASH_VERSION" ]; then
    : "${DOTFILES_CLUSTER_FAST_MODE:=1}"
    if [ "$DOTFILES_CLUSTER_FAST_MODE" = "1" ]; then
        export DOTFILES_DISABLE_BASH_COMPLETION="${DOTFILES_DISABLE_BASH_COMPLETION:-1}"
        export STARSHIP_DISABLE="${STARSHIP_DISABLE:-true}"

        # Keep frequently-written caches off high-latency network metadata paths.
        export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/$USER/.cache}"
        export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-$XDG_CACHE_HOME/npm}"
        export PIP_CACHE_DIR="${PIP_CACHE_DIR:-$XDG_CACHE_HOME/pip}"
        export UV_CACHE_DIR="${UV_CACHE_DIR:-$XDG_CACHE_HOME/uv}"

        mkdir -p "$XDG_CACHE_HOME" "$NPM_CONFIG_CACHE" "$PIP_CACHE_DIR" "$UV_CACHE_DIR" 2>/dev/null || true
    fi
fi

# Loads GEMINI_API_KEY from ~/.secrets/gemini for this one process.
gemini-api() ( secrets gemini; command gemini "$@" )

_dotfiles_is_login_shell=false
if [ -n "$BASH_VERSION" ]; then
    shopt -q login_shell && _dotfiles_is_login_shell=true
elif [ -n "$ZSH_VERSION" ]; then
    [[ -o login ]] && _dotfiles_is_login_shell=true
fi

# Each `module load` costs 10-80s over NFS on busy login nodes, so keep login
# lean: only eth_proxy (proxy env vars for outbound network), and only once —
# the exported sentinel skips the second pass when bashrc re-sources .profile.
if [[ $- == *i* ]] && [ "$_dotfiles_is_login_shell" = true ] \
    && [ -z "${DOTFILES_EU_MODULES_LOADED:-}" ]; then
    module load eth_proxy 2>/dev/null
    export DOTFILES_EU_MODULES_LOADED=1
fi
unset _dotfiles_is_login_shell

# Compiler/CUDA modules on demand — not at login, they cost minutes
devmods() {
    module load stack/2024-06 gcc/12.2.0 cuda/12.8.0
}

# Skip heavy cluster initialization for AI agents
# Module loads can hang if cluster services are slow/unresponsive
# Any non-empty AI_AGENT means an agent is driving this shell. Each tool sets its
# own name -- Claude Code its own identifier, "codex" and "opencode" from the
# wrappers in aliases/aliases.symlink -- so test for "set at all", never for one
# specific value. Set AI_AGENT=0 to force the human path.
if [ -z "$AI_AGENT" ] || [ "$AI_AGENT" = "0" ]; then
    [ -f /etc/profile.d/lmod.sh ] && source /etc/profile.d/lmod.sh
    [ -f /etc/profile.d/module_path.sh ] && source /etc/profile.d/module_path.sh

    # Starship config switcher: use fast config on cluster filesystems
    # (disables git scanning, language detection, custom commands)
    set_starship_config() {
        if [[ $PWD == /cluster/* ]]; then
            export STARSHIP_CONFIG=~/.starship_nogit.toml
        else
            export STARSHIP_CONFIG=~/.starship.toml
        fi
    }
    if [ -n "$ZSH_VERSION" ]; then
        precmd_functions+=(set_starship_config)
    elif [ -n "$BASH_VERSION" ] && [ "${STARSHIP_DISABLE:-}" != "true" ]; then
        PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}set_starship_config"
    fi

fi

# Add pixi to path if present
if [ -d "$HOME/.pixi/bin" ]; then
    PATH="$PATH:$HOME/.pixi/bin"
fi
