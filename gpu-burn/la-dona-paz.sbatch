#!/bin/bash
# Author: Dolphin Whisperer
# Email: jeremy.bell@nih.gov
# Date: 2024.12.12
# Duration: ~5 min/server/8 GPUs
# Description: This script verifies that all GPUs in the cluster nodes are functioning by testing the sustained computational performance of GPUs for 5 minutes.
# It does this by running a workload designed to heavily utilize GPU resources and assessing the thermal and power stability of the GPUs during continuous high usage.
# This can be adjusted to run w/o SLURM.
# Home: https://github.com/wilicc/gpu-burn

#SBATCH --job-name=La_Dona_Paz
#SBATCH --partition=gpu
#SBATCH --gres=gpu:8
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --output=slurm-out-gpu-burn-%N-%J.log
#SBATCH --error=slurm-err-gpu-burn-%N-%J.log

# Load necessary modules
ml gpu-burn

# Run gpu-burn for 5 minutes on each node
srun --gres=gpu:8 --exclusive gpu_burn -d 300
