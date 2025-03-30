#!/bin/bash
# Author: Jeremy Bell
# Email: jeremy.bell@nih.gov
# Date: 2024.02.27
# Description: This script runs a series of 'dd' commands to benchmark the filesystem

LOGFILE="./p-dd.log"
echo "Filesystem Benchmark Log" > $LOGFILE
echo "----------------------------------------------" >> $LOGFILE

for cmd in \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/1-1G bs=1G count=1" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/10-1G bs=1G count=10" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/100-1G bs=1G count=100" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/1000-1G bs=1G count=1000" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/1-10G bs=10G count=1" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/10-10G bs=10G count=10" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/100-10G bs=10G count=100" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/1-1M bs=1M count=1" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/10-1M bs=1M count=10" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/100-1M bs=1M count=100" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/1000-1M bs=1M count=1000" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/10000-1M bs=1M count=10000" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/100000-1M bs=1M count=100000" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/1000000-1M bs=1M count=1000000" \
    "dd iflag=fullblock if=/dev/zero of=/path/to/file/10000000-1M bs=1M count=10000000";
    do
    echo "Running: $cmd" | tee -a $LOGFILE
    { time $cmd; } 2>&1 | tee -a $LOGFILE
    echo "----------------------------------------------" | tee -a $LOGFILE

done
