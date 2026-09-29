#!/bin/bash
# Configuration for HPC cluster environments

# Core dumps off. Login nodes have `ulimit -c unlimited` and core_pattern=core_%h_%p,
# so any crash (python, an agent CLI, ...) writes a multi-GB core_<host>_<pid> into the
# cwd on a shared filesystem. Set shell-wide so every child process inherits it.
# Re-enable per shell with `ulimit -c unlimited` when a core is actually wanted.
ulimit -c 0 2>/dev/null || true

# Cluster-specific paths
export PATH="$HOME/.local/bin:$PATH"
export PATH=$HOME/cuda/bin:$HOME/.claude/local:$PATH
export XDG_CONFIG_HOME="$HOME/.config"

# uv cache off $HOME. On CSCS/Alps $HOME is /vast (50 GB quota) and the uv cache
# alone reached 5.6 GB / 11% of it. Scratch has no practical size limit; the cache
# is fully regenerable, so a scratch purge costs a re-download, nothing more.
# Guarded on the directory: this file is shared with other clusters (Euler etc.)
# where /iopsstor does not exist, and there uv keeps its default ~/.cache/uv.
if [ -d /iopsstor/scratch/cscs/"$USER" ]; then
    export UV_CACHE_DIR="/iopsstor/scratch/cscs/$USER/CACHE/uv"
fi

# GPU
alias nsmi="nvidia-smi"

# Slurm shortcuts (qsq* = squeue, qw* = watch, sqg = GPU detail)
alias qsq="squeue -u \$(whoami) -o \"%.18i %.12P %.20j %.3T %.12M %.10l %.6D %.4C %R\""
alias qsqa='squeue -o "%.18i %.12P %.20j %.8u %.3T %.12M %.10l %.6D %.4C %.16b %R" | sed "1!s/gres\/gpu:[^:]*://g; 1!s/N\/A/0/g"'
alias qsqd="squeue -u \$(whoami) -o \"%.14i %.20j %.2t %.10M %.9l %.5D %16R %5K %3C %o\""
alias qsqm='SACCT_FORMAT="JobID%20,JobName,User,Partition,NodeList,Elapsed,State,ExitCode,MaxRSS,AllocTRES%32" sacct'
sqg() { squeue -u "$(whoami)" -h -o "%i %j" | while read jobid name; do gpu=$(scontrol show job "$jobid" 2>/dev/null | sed -n 's/.*gres\/gpu:\([0-9]\+\).*/\1/p' | head -1); echo "Job $jobid ($name): ${gpu:-0} GPUs"; done; }
qsqc() { [[ -z "$1" || "$1" =~ ^[[:space:]]*$ ]] && { echo "Error: Pattern required" >&2; return 1; }; squeue -u "$(whoami)" -h -o "%i %j" | grep "$1" | awk '{print $1}' | xargs scancel; }
alias qwsq="watch -n 10 'squeue -u \$(whoami) -o \"%.18i %.12P %.20j %.3T %.12M %.10l %.6D %.4C %R\"'"
alias qwsqa='watch -n 10 '\''squeue -o "%.18i %.12P %.20j %.8u %.3T %.12M %.10l %.6D %.4C %.16b %R" | sed "1!s/gres\/gpu:[^:]*://g; 1!s/N\/A/0/g"'\'''
alias qwsqd="watch -n 10 -d 'squeue -u \$(whoami) -o \"%.14i %.20j %.2t %.10M %.9l %.5D %16R %5K %3C %o\"'"

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
    elif [ -n "$BASH_VERSION" ]; then
        PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}set_starship_config"
    fi

fi

# Add pixi to path if present
if [ -d "$HOME/.pixi/bin" ]; then
    PATH="$PATH:$HOME/.pixi/bin"
fi
