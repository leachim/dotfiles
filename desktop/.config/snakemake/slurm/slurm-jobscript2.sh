#!/bin/bash
#! Generic SLURM job script for usage with snakemake and slurm autoconfig
properties={properties}

#!#############################################################
#!#### Modify the options in this section as appropriate ######
#!#############################################################

#!SBATCH --job-name=10-index
#SBATCH --job-name=10-index
#SBATCH --nodes=1
#SBATCH --ntasks=1
#!SBATCH --mem-per-cpu=32G
#!SBATCH --time=200:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=michael.schneider@cruk.cam.ac.uk
#!SBATCH --no-requeue
#!SBATCH --output=/home/%u/project1/Logs/%x/slurm.%A.%x.out
#!SBATCH --error=/home/%u/project1/Logs/%x/slurm.%A.%x.err

###############################################################
### Execute script                                         ####
###############################################################
echo -e "JobID: $SLURM_JOB_ID\n======"
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"

#/bin/bash $HOME/project1/src/10-index.sh 
#print(jobscript)
#print(jobscript)
{exec_job}
