#!/bin/bash
# Author: Dolphin Whisperer
# Email: jeremy.bell@nih.gov
# Date: 2024.12.06
# Duration: ~45 min
# Description: This script uses Picard's MarkDuplicates tool to identify and remove duplicate reads in sequencing data.
# It loops through input BAM files, checks if the corresponding output file already exists, and submits individual SLURM jobs to process each file in parallel.
# Picard is installed via Apptainer on Skyline, which the test-suite script calls.
# Home: http://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates

# Navigate to the working directory containing input BAM files and where results will be stored
cd /data/sysadmins/skyline-test-suite/picard-remove-duplicates

# Load the Picard module
ml picard/3.1.1

# Set a restrictive umask so that newly created files are accessible only to the owner and group
umask 0007

# Create output directories for processed files, metrics, and logs
mkdir -p output metrics logs

# Path to the Picard container
CONTAINER_PATH=/data/apps/software/containers/picard/picard_3.1.1.sif

# Loop over each BAM file in the '../../input' directory
for input in ../../input/*
do
    # Check if the corresponding output file exists
    if [ ! -f output/$( basename $input .bam )_nodup.bam ]
    then
        # Extract the sample number from the input file name (assumes format like 6801_sorted.bam)
        SAMPLE_NUM=$( basename $input _sorted.bam )
        
        # Big Brother
        echo "Processing the Goods - $input"
        echo "Launching SLURM job for SAMPLE_NUM: $SAMPLE_NUM"

        # Submit a SLURM job to process the current input file with Picard MarkDuplicates
        srun -p all -c 16 --mem=192G -J STARFLEET-${SAMPLE_NUM} -o logs/stdout-%J.txt -e logs/stderr-%J.txt \
            apptainer exec --home $PWD --bind /data:/data $CONTAINER_PATH java "-Xmx90g" -jar /usr/picard/picard.jar MarkDuplicates \
            REMOVE_DUPLICATES=true CREATE_INDEX=true ASSUME_SORTED=true \
            INPUT=$input \
            OUTPUT=output/$( basename $input .bam )_nodup.bam \
            METRICS_FILE=metrics/$( basename $input _sorted.bam )_metrics.txt &
    fi
done

# Wait for all background jobs (SLURM tasks) to complete before exiting the script
wait
