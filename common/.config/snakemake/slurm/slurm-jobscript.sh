#!/bin/bash
# properties = {properties}
# note that the above line should not be changed one iota
echo -e "JobID: $SLURM_JOB_ID\n======"
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"
{exec_job}
echo "End time: `date`"
