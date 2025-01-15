#!/bin/bash
# Author: Jeremy Bell
# Date: 2024.11.11
# Description: This script submits a SLURM job using the dd and rsync commands.
# It evaluates the time taken to create, transfer, and delete files of various sizes.
# The results are logged for performance analysis
# Change source/dest/results files - can be adjusted to work w/o SLURM

#SBATCH --job-name=ddRRd
#SBATCH --output=ddRRd.out
#SBATCH --error=ddRRd.err
#SBATCH --time=00:33:33
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

# Load rsync module
ml rsync

# Directories for files (CHANGE THESE - leave trailing backslashes off for rsync playnice - heffalumps n woozles)
SOURCE_DIR=</path/to/source/directory>
TARGET_DIR=</path/to/target/directory>
RESULTS_FILE=</path/to/results/file/>round-trip.txt

# Create directories
mkdir -p $SOURCE_DIR $TARGET_DIR

# File sizes
FILE_SIZES=("1K" "10K" "100K" "1000K" "10000K" "100000K" "1M" "10M" "100M" "1000M" "10000M" "1G" "10G" "100G" "1000G")

# Start tracking runtime
printf "%-8s %-15s %-15s %-15s %-15s\n" "File Size" "Creation Time" "Rsync-to Time" "Rsync-back Time" "Deletion Time" > $RESULTS_FILE

for SIZE in "${FILE_SIZES[@]}"; do
    FILE_NAME="file_${SIZE}.bin"
    SOURCE_FILE="$SOURCE_DIR/$FILE_NAME"

    # Ensure file size is interpretable by dd
    VALID_SIZE=$(echo "$SIZE" | sed 's/G/000M/;s/M/000K/;s/K//')

    # Measure file creation time
    start_time=$(date +%s.%N)
    dd iflag=fullblock if=/dev/zero of=$SOURCE_FILE bs=1024 count=$VALID_SIZE > /dev/null 2>&1
    end_time=$(date +%s.%N)
    creation_time=$(echo "$end_time - $start_time" | bc)

    # Verify file exists
    if [[ ! -f $SOURCE_FILE ]]; then
        echo "Error: Failed to create file $SOURCE_FILE"
        exit 1
    fi

    # Measure rsync to target time
    start_time=$(date +%s.%N)
    rsync -av $SOURCE_FILE $TARGET_DIR > /dev/null 2>&1
    end_time=$(date +%s.%N)
    rsync_to_time=$(echo "$end_time - $start_time" | bc)

    # Measure rsync back time
    start_time=$(date +%s.%N)
    rsync -av $TARGET_DIR/$FILE_NAME $SOURCE_DIR > /dev/null 2>&1
    end_time=$(date +%s.%N)
    rsync_back_time=$(echo "$end_time - $start_time" | bc)

    # Measure deletion time
    start_time=$(date +%s.%N)
    rm -f $SOURCE_FILE $TARGET_DIR/$FILE_NAME > /dev/null 2>&1
    end_time=$(date +%s.%N)
    deletion_time=$(echo "$end_time - $start_time" | bc)

    # Log the results
    printf "%-8s %-15.9f %-15.9f %-15.9f %-15.9f\n" $SIZE $creation_time $rsync_to_time $rsync_back_time $deletion_time >> $RESULTS_FILE
done

echo "Test completed. Results stored in $RESULTS_FILE"
