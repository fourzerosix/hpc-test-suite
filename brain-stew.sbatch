#!/bin/bash
# Author: Jeremy Bell
# Email: jeremy.bell@nih.gov
# Date: 2024.11.01
# Description: This script 

#SBATCH --job-name=N!GHT_N!GHT
#SBATCH --output=brain-stew_output_%A_%a.txt
#SBATCH --time=1
#SBATCH --mem=1GB
#SBATCH --nodes=10               # Request 10 nodes 
#SBATCH --ntasks-per-node=1      # 1 task per node
#SBATCH --array=1-10             # 10 member array

# srun ensures the command is executed on each allocated task
srun --ntasks=10 sleep 1         # Adjust the number of tasks if you modify --nodes or --ntasks-per-node
