#!/bin/bash
# Author: Jeremy Bell
# Date: 2024.12.05
# Duration: <5 min
# Description: This script runs IOR (Interleaved Or Random) benchmarks to evaluate the I/O performance.
# It systematically tests different transfer and block sizes to assess how well the system handles various I/O workloads.
# The IOR benchmark tests the performance of the underlying file system using read/write operations with various transfer and block sizes to simulate diverse real-world workload (e.g., small metadata-intensive writes vs. large sequential data transfers).
# It Utilizes MPI with OpenMPI and integrates with SLURM for workload management which tests the proper functioning of the MPI stack and SLURM scheduler.
# It tests the system's ability to handle parallel I/O efficiently by running processes concurrently and by varying the IOR_SEGMENTS and running on a single node.
# The script evaluates the ability of the node and its file system to scale with increasing workload sizes and captures potential failures in individual tests and logs them for troubleshooting, helping identify instability in the system or file system.
# Home: https://github.com/hpc/ior

#SBATCH --job-name=D!$TR!BUT3D_D0NK3Y$
#SBATCH --nodes=1-16          # Request between 1 and 16 nodes
#SBATCH --ntasks=100          # Total tasks (adjust as needed for your workload)
#SBATCH --time=01:11:11
#SBATCH --output=ior-distributed.%j.out

# Load necessary modules
ml openmpi/5.0.3-w3bgmn3 || { echo "Failed to load OpenMPI module"; exit 1; }
ml ior/3.3.0-h5e6u5n || { echo "Failed to load IOR module"; exit 1; }

# Define parameters
IOR_TRANSFER_SIZES=("4k" "2m" "16m" "1g")  # Array of transfer sizes to test
IOR_BLOCK_SIZES=("4k" "2m" "16m" "1g")    # Array of block sizes to test
IOR_SEGMENTS=${1:-16}                     # Default number of segments if not provided

# Output and working directories
OUTPUT_DIR="ior_results_$(date +%Y%m%d_%H%M%S)"
IOR_WORKING_DIR="$OUTPUT_DIR/ior_test_files"
mkdir -p "$OUTPUT_DIR" "$IOR_WORKING_DIR"

# Temporary directory for PRTE
LOCAL_TMPDIR="/tmp/prte_tmp_$SLURM_JOB_ID"
mkdir -p "$LOCAL_TMPDIR"
export TMPDIR="$LOCAL_TMPDIR"
export PRTE_TMPDIR_BASE="$LOCAL_TMPDIR"

# Log environment and initial setup
echo "IOR Benchmark Script" > "$OUTPUT_DIR/ior-distributed.log"
echo "Date: $(date)" >> "$OUTPUT_DIR/ior-distributed.log"
echo "Nodes allocated: $SLURM_JOB_NODELIST" >> "$OUTPUT_DIR/ior-distributed.log"
echo "Total tasks: $SLURM_NTASKS" >> "$OUTPUT_DIR/ior-distributed.log"
echo "CPUs per node: $SLURM_CPUS_ON_NODE" >> "$OUTPUT_DIR/ior-distributed.log"
echo "Transfer sizes: ${IOR_TRANSFER_SIZES[*]}" >> "$OUTPUT_DIR/ior-distributed.log"
echo "Block sizes: ${IOR_BLOCK_SIZES[*]}" >> "$OUTPUT_DIR/ior-distributed.log"
echo "Segments: $IOR_SEGMENTS" >> "$OUTPUT_DIR/ior-distributed.log"
echo "Temporary directory for PRTE: $LOCAL_TMPDIR" >> "$OUTPUT_DIR/ior-distributed.log"
echo "Working directory for IOR: $IOR_WORKING_DIR" >> "$OUTPUT_DIR/ior-distributed.log"
echo "Starting tests..." >> "$OUTPUT_DIR/ior-distributed.log"

# Run tests
for TRANSFER_SIZE in "${IOR_TRANSFER_SIZES[@]}"; do
  for BLOCK_SIZE in "${IOR_BLOCK_SIZES[@]}"; do
    LOG_FILE="$OUTPUT_DIR/ior_t${TRANSFER_SIZE}_b${BLOCK_SIZE}.log"
    echo "Running IOR with transfer size $TRANSFER_SIZE, block size $BLOCK_SIZE" >> "$OUTPUT_DIR/ior-distributed.log"

    srun --distribution=block:block mpirun -n $SLURM_NTASKS ior -t "$TRANSFER_SIZE" -b "$BLOCK_SIZE" -s "$IOR_SEGMENTS" -F -C -e -o "$IOR_WORKING_DIR/testFile" > "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
      echo "Test with transfer size $TRANSFER_SIZE and block size $BLOCK_SIZE completed successfully." >> "$OUTPUT_DIR/ior-distributed.log"
    else
      echo "Test with transfer size $TRANSFER_SIZE and block size $BLOCK_SIZE failed. Check $LOG_FILE for details." >> "$OUTPUT_DIR/ior-distributed.log"
    fi
  done
done

# Clean up temporary directory
rm -rf "$LOCAL_TMPDIR"

# Final completion message
echo "IOR benchmarking completed. Results saved in $OUTPUT_DIR." >> "$OUTPUT_DIR/ior-distributed.log"
