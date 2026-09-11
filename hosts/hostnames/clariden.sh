#!/bin/bash
# Config for Clariden/Daint cluster nodes (aarch64, matches clariden-*, daint-*)
# Daint.sh is a symlink to this file — both clusters share the same architecture
# GPU nodes available but only used via containers (enroot/docker/podman)
# No module loads needed

# aarch64-specific prefix (shadows ~/.local/bin from hpc.sh)
export PATH="$HOME/.local/aarch64/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/aarch64/lib:${LD_LIBRARY_PATH:-}"
export CPATH="$HOME/.local/aarch64/include:${CPATH:-}"

# Override Starship cluster filesystem detection (/capstor instead of /cluster)
# Any non-empty AI_AGENT means an agent is driving this shell. Each tool sets its
# own name -- Claude Code its own identifier, "codex" and "opencode" from the
# wrappers in aliases/aliases.symlink -- so test for "set at all", never for one
# specific value. Set AI_AGENT=0 to force the human path.
if [ -z "$AI_AGENT" ] || [ "$AI_AGENT" = "0" ]; then
    set_starship_config() {
        if [[ $PWD == /capstor/* ]]; then
            export STARSHIP_CONFIG=~/.starship_nogit.toml
        else
            export STARSHIP_CONFIG=~/.starship.toml
        fi
    }
fi

# Podman-based container runtime (no Docker daemon on Clariden)
# AWS_ACCOUNT is an ECR registry account id, set in ~/.localrc.
aws-login() { aws ecr get-login-password | podman login --username AWS --password-stdin "$AWS_ACCOUNT" ; }
alias d="podman"
alias dima="podman images"
alias dim="podman images -f dangling=false"
alias dps="podman ps"
