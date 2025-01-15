#!/bin/bash
#
# Author: Dolphin Whisperer
# Email: jeremy.bell@nih.gov
# Created: 2024-12-21
# Description: This script performs 40+ common admin/user commands and records the output to a log file
#
#SBATCH --job-name=D33P_BR3@TH
#SBATCH --output=cavity-search.log
#SBATCH --ntasks=1
#SBATCH --time=00:10:00
#SBATCH --partition=int

# Create a temporary directory for benchmarking
WORKDIR=$(mktemp -d)
LOGFILE="cavity-search.log"
SUMMARYFILE="cavity-search.txt"

# Ensure the temporary directory is cleaned up on exit
trap "rm -rf $WORKDIR" EXIT

# Write a header to the log file
echo "Command Benchmark Results" > $LOGFILE
echo "===========================" >> $LOGFILE

# Define a function to benchmark a command
benchmark_command() {
    local cmd="$1"
    local cmd_short=$(echo "$cmd" | sed "s|$WORKDIR/||g; s|$WORKDIR||g" | xargs) # Remove paths and trim spaces
    echo "Benchmarking: $cmd" >> $LOGFILE
    { /usr/bin/time -f "%e" bash -c "$cmd"; } 2>> $LOGFILE
    local real_time=$(tail -n 1 $LOGFILE | awk '{print $1}')
    printf "%-50s %10s\n" "$cmd_short" "$real_time" >> $SUMMARYFILE
    echo >> $LOGFILE
}

# Initialize the summary file
echo -e "%-50s %10s\n" "Command" "Time (s:tenths:hundredths)" > $SUMMARYFILE
printf "%-50s %10s\n" "----------------------------------------------" "-------------------" >> $SUMMARYFILE

# Benchmark trivial commands
benchmark_command "cd $WORKDIR"
benchmark_command "ls $WORKDIR"
benchmark_command "mkdir $WORKDIR/test_dir"
benchmark_command "mv $WORKDIR/test_dir $WORKDIR/test_dir_renamed"
benchmark_command "cp -r $WORKDIR/test_dir_renamed $WORKDIR/test_dir_copy"
benchmark_command "rm -rf $WORKDIR/test_dir_copy"
benchmark_command "df -h"
benchmark_command "du -sh $WORKDIR"
benchmark_command "touch $WORKDIR/test_file"
benchmark_command "echo 'Hello World' > $WORKDIR/test_file"
benchmark_command "cat $WORKDIR/test_file"
benchmark_command "rm $WORKDIR/test_file"
benchmark_command "sleep 1"

# Additional useful commands
benchmark_command "find $WORKDIR -type f"
benchmark_command "grep 'Hello' $WORKDIR/test_file 2>/dev/null || true"
benchmark_command "head -n 1 /etc/passwd"
benchmark_command "tail -n 1 /etc/passwd"
benchmark_command "stat $WORKDIR"
benchmark_command "whoami"
benchmark_command "hostname"
benchmark_command "uptime"
benchmark_command "env"
benchmark_command "top -bn1 | head -n 10"
benchmark_command "ps aux | head -n 10"
benchmark_command "chmod 700 $WORKDIR"
benchmark_command "chown $(whoami):$(whoami) $WORKDIR"
benchmark_command "ln -s /etc/passwd $WORKDIR/passwd_link"
benchmark_command "readlink $WORKDIR/passwd_link"
benchmark_command "rm $WORKDIR/passwd_link"
benchmark_command "date"
benchmark_command "cal"
benchmark_command "yes | head -n 1000 > $WORKDIR/yes_output"
benchmark_command "wc -l $WORKDIR/yes_output"
benchmark_command "rm $WORKDIR/yes_output"

# Network-related commands
benchmark_command "ping -c 4 8.8.8.8"
benchmark_command "curl -o /dev/null -s -w '%{time_total}\n' https://www.google.com"
benchmark_command "wget -qO- https://www.google.com > /dev/null"
benchmark_command "nslookup google.com"
benchmark_command "traceroute google.com"
benchmark_command "ifconfig"
benchmark_command "ip a"

# Module system commands
benchmark_command "module avail"
benchmark_command "module list"
benchmark_command "module load nonexistent_module 2>/dev/null || true"
benchmark_command "module load rsync && rsync --version"
benchmark_command "module unload rsync && module list"

# Finalize the log file
echo "Benchmarking complete. Results saved in $LOGFILE." >> $LOGFILE

# Send the summary via email
#mail -s "Command Benchmark Summary" jeremy.bell@nih.gov < cavity-search.log
