#!/bin/bash
#
# Author: Jeremy Bell
# Created: 2024.12.04
# Description: Tests loading all R package in .libPaths().

# Define the SLURM partitions to use for the jobs (comma-separated list of partitions)
export PARTITION="all"

# Change directory to the R package library path
cd /data//home/belljs/R-package-library

# Load R
ml r-4.4.1-ipcobrc

# Set shell limits for the maximum number of open files, stack size, and user processes
ulimit -n 32000  # Maximum number of open files
ulimit -s 32000  # Maximum stack size
ulimit -u 32768  # Maximum number of user processes

# Set the default file creation mask to allow group write permissions while restricting others
umask 0007

# Create a temporary file for storing the R script to load all packages, stored in the current directory
export RLOADALL=$( mktemp --suffix=.R -p ./ )

# Find all R packages available in the directories returned by .libPaths()
# Exclude certain entries:
# - Empty entries or invalid ones (via `egrep -v '^$|:$'`)
# - Non-package directories like "translations" and problematic packages like "iplots"
# Sort the remaining package names to ensure uniqueness
for pkg in $( Rscript --no-save -e 'foo=.libPaths(); cat(foo)' | xargs ls | egrep -v '^$|:$|translations|iplots' | sort -u )
do
    # Append a line to the temporary R script to suppress messages and load the current package ($pkg)
    echo 'suppressPackageStartupMessages(library('$pkg'))' >>$RLOADALL

    # Submit a SLURM job to load the current package
    # - Job name (-J) includes the package name for easier tracking
    # - Standard output and error are redirected to specific log files under slurm_logs/
    # - Allocates 1 CPU core and 2 GB of memory for the job
    # - Uses the partitions defined earlier in $PARTITION
    srun -J R-${pkg} -o slurm_logs/stdout-R-${pkg}-%J.txt -e slurm_logs/stderr-R-${pkg}-%J.txt -c 1 --mem 2g -p $PARTITION \
    Rscript --no-save -e 'suppressPackageStartupMessages(library('$pkg'))' &
done

# After loading individual packages, load (almost) all packages in a single R session
# Submit a SLURM job for this task
# - Allocates 4 CPU cores and uses the partitions defined earlier
# - Outputs logs to separate files under slurm_logs/
srun -J R-loadall -o slurm_logs/stdout-R-load-all-%J.txt -e slurm_logs/stderr-R-loadall-%J.txt -c 1 -p $PARTITION Rscript --no-save $RLOADALL &

# Wait for all background jobs (individual package loads and load-all) to complete
wait

# Remove the temporary R script used for loading all packages
rm -f $RLOADALL

# Cleanup: Remove empty SLURM log files (those with size 0)
# - Finds files matching "std*.txt" in the slurm_logs/ directory
# - Executes the `rm` command on those files
find slurm_logs/ -size 0 -name std\*.txt -exec rm {} \;
