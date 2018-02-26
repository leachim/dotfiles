#!/bin/bash

NOW=$(date "+%Y-%m-%d")
mkdir $HOME/conda-$NOW
ENVS=$(conda env list | grep '^\w' | cut -d' ' -f1)
for env in $ENVS; do
    source activate $env
    conda env export > $HOME/conda-$NOW/$env.yml
    echo "Exporting $env"
done

zip -j -r $HOME/conda-$NOW.zip $HOME/conda-$NOW
rm -rf $HOME/conda-$NOW
