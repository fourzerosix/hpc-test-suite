#!/bin/bash
# Author: Jeremy Bell
# Date: 2024.11.11
# Description: The script is designed to perform a memory test on GPUs across all nodes in the gpu partition using the cuda_memtest utility.
# It ensures that GPU memory on each node is validated for errors, which is crucial for maintaining the reliability of GPU resources in a cluster environment.

#SBATCH --job-name=SPHYR43N4
#SBATCH --partition=gpu         # Specify the GPU partition
#SBATCH --nodes=ALL             # Request all nodes in the GPU partition
#SBATCH --ntasks-per-node=1     # One task per node
#SBATCH --cpus-per-task=1       # Number of CPUs per task
#SBATCH --time=00:20:00         # Time limit for the job
#SBATCH --output=cuda_memtest_%j.log  # Output file for logs

# Load the cuda_memtest module
module load cuda-memtest/master-tbzpmub

# Run cuda_memtest on each allocated node
srun --ntasks=$SLURM_JOB_NUM_NODES --nodes=$SLURM_JOB_NUM_NODES --ntasks-per-node=1 cuda_memtest
