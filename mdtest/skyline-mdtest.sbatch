#!/bin/bash
# Author: Dolphin Whisperer
# Email: jeremy.bell@nih.gov
# Date: 2024.12.07
# Duration: ~5 min/server/8 GPUs
# Description: This script tests the metadata performance of the underlying file system on a cluster, which can reveal latency and throughput for creating, reading, and linking files and directories.
# It also tests scalability and performance characteristics of the file system under MPI parallelism.
# Home: https://github.com/LLNL/mdtest

#SBATCH --job-name=MD2020      
#SBATCH --output=mdtest_%j.out   
#SBATCH --error=mdtest_%j.err     
#SBATCH --ntasks=1                
#SBATCH --cpus-per-task=1       
#SBATCH --time=00:04:44          
#SBATCH --partition=all      
#SBATCH --mail-type=END,FAIL    
#SBATCH --mail-user=jeremy.bell@nih.gov

# Load necessary modules
ml openmpi/5.0.3-w3bgmn3
ml ior/3.3.0-h5e6u5n

# Define/Create test dir
TEST_DIR=./out/mdtest_run_$(date +%S)
mkdir -p "$TEST_DIR"

# Print diag info
echo "Starting job at: $(date)"
echo "Running on node: $(hostname)"
echo "Using $SLURM_CPUS_ON_NODE CPUs on this node"

# Run mdtest commands with full output redirection
echo "Running mdtest: default mode"
srun mdtest -I 10 -z 5 -b 2 -d "$TEST_DIR" -v > mdtest_default_%J.out 2> mdtest_default_%J.err
if [ $? -ne 0 ]; then
  echo "Error: mdtest command failed (default mode)"
  exit 1
fi

echo "Running mdtest: read mode (-R)"
srun mdtest -I 10 -z 5 -b 2 -d "$TEST_DIR" -v -R > mdtest_read_%J.out 2> mdtest_read_%J.err
if [ $? -ne 0 ]; then
  echo "Error: mdtest command failed (read mode)"
  exit 1
fi

echo "Running mdtest: link mode (-L)"
srun mdtest -I 10 -z 5 -b 2 -d "$TEST_DIR" -v -L > mdtest_link_%J.out 2> mdtest_link_%J.err
if [ $? -ne 0 ]; then
  echo "Error: mdtest command failed (link mode)"
  exit 1
fi

echo "All mdtest commands completed successfully at: $(date) - may peace be with you."
