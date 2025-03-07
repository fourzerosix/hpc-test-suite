#!/bin/bash
# Author: Jeremy Bell
# Email: jeremy.bell@nih.gov
# Date: 2025.03.06
# Description: This script tests SLURM's ability to execute a job array.

#SBATCH --job-name=aRR@Y0F$UN$H!Ne
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH --partition=all
#SBATCH --array=[1-1000]%20
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@place.com
#SBATCH -o %x_%A_%a.out
#SBATCH -e %x_%A_%a.err

echo "host name : " `hostname`
echo This is array task number $SLURM_ARRAY_TASK_ID
