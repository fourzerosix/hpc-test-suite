#!/bin/bash
#SBATCH --job-name=STR3$$3D           # Set the job name
#SBATCH --output=stress-ng-tests-%j.out      # Redirect standard output to a file
#SBATCH --error=stress-ng-tests-%j.err       # Redirect standard error to a file
#SBATCH --partition=all                 # Specify the partition to run the job on
#SBATCH --nodes=1                            # Request 1 node
#SBATCH --ntasks=1                           # Request 1 task
#SBATCH --time=24:00:00                      # Set the maximum time for the job (24 hours)
#SBATCH --mail-type=END,FAIL                 # Notify on job end or failure
#SBATCH --mail-user=jeremy.bell@nih.gov   # Email address for notifications

# Load the stress-ng module
ml stress-ng/0.18.06-qav7ybu

# Define an array of stress-ng commands
stress_ng_commands=(
    "stress-ng --all 4 --timeout 5m"                  # Stress all resources with 4 stressors for 5 minutes
    "stress-ng --all 8 --with cpu,hash,nop,vm --timeout 1m"  # Stress CPU, hash, nop, and VM resources with 8 stressors for 1 minute
    "stress-ng --cpu -1 --cpu-method all -t 1h --cpu-load 90" # Stress CPU with all methods for 1 hour, aiming for 90% load
    "stress-ng --cpu 0 --cpu-method all -t 10m"       # Stress CPU with all methods for 10 minutes, targeting 0% load
    "stress-ng --cpu 4 --cpu-method fft --cpu-ops 10000 --metrics-brief" # Stress 4 CPU cores using FFT method with 10,000 operations and brief metrics
    "stress-ng --cpu 4 --io 2 --vm 1 --vm-bytes 1G --timeout 60s"  # Stress CPU, I/O, and VM with 1GB allocated for VM, for 60 seconds
    "stress-ng --cpu 4 --vm 2 --hdd 1 --fork 8 --timeout 1m --metrics" # Stress CPU, VM, HDD, and fork 8 tasks for 1 minute with metrics
    "stress-ng --cpu 64 --cpu-method all --verify -t 10m --metrics-brief"  # Stress 64 CPUs using all methods for 10 minutes with verification and brief metrics
    "stress-ng --cpu 8 --cpu-ops 800000"              # Stress 8 CPUs with 800,000 operations each
    "stress-ng --cyclic 1 --cyclic-dist 2500 --cyclic-method clock_ns --cyclic-prio 100 --cyclic-sleep 10000 --hdd 0 -t 1m"  # Test cyclic tasks with custom parameters for 1 minute
    "stress-ng --intmath 0 -t 1m --c-states"         # Stress integer math operations for 1 minute, testing CPU C-states
    "stress-ng --iomix 2 --iomix-bytes 10% -t 10m"    # Stress I/O operations with 10% of data for 10 minutes
    "stress-ng --matrix -1 --tz -t 60"               # Stress matrix operations with all available methods for 60 seconds
    "stress-ng --random 32 -x numa,hdd,key"         # Stress random operations excluding NUMA, HDD, and keyboard for 32 iterations
    "stress-ng --random 64"                          # Stress random operations for 64 iterations
    "stress-ng --seq 8 --with cpu,hash,nop,vm --timeout 1m --progress" # Sequential stress with CPU, hash, nop, and VM for 8 iterations with progress reporting
    "stress-ng --sequential -1 -t 10m"               # Sequential stress test with all resources for 10 minutes
    "stress-ng --sequential 2 --timeout 2m --metrics" # Sequential stress test on 2 resources for 2 minutes with metrics
    "stress-ng --sequential 4 --class vm --exclude bigheap,brk,stack" # Sequential VM stress test excluding bigheap, brk, and stack
    "stress-ng --sequential 8 --class io -t 5m --times"  # Sequential I/O stress test for 5 minutes with time reporting
    "stress-ng --taskset 0,2-3 --cpu 3"              # Pin stress-ng to CPU cores 0, 2, and 3, and stress 3 CPUs
    "stress-ng --taskset odd --cpu 32"               # Pin stress-ng to odd-numbered CPU cores, and stress 32 CPUs
    "stress-ng --vdso 1 -t 5 --metrics"              # Test VDSO (Virtual Dynamic Shared Object) functionality for 5 seconds with metrics
    "stress-ng --vm 8 --vm-bytes 80% -t 10m"         # Stress 8 VMs with 80% memory usage for 10 minutes
    "stress-ng --with cpu,matrix,vecmath,fp --permute 5 -t 10s"  # Stress CPU, matrix, vector math, and FP operations with 5 permutations for 10 seconds
    "stress-ng --all -1 --maximize --aggressive"     # Stress all resources with maximum intensity and aggressive stress tests
    "stress-ng --with cpu,matrix,vecmath,fp --seq 8 -t 1m"  # Sequential stress on CPU, matrix, vector math, and FP for 8 iterations, 1 minute
)

# Execute each stress-ng command in serial
for cmd in "${stress_ng_commands[@]}"; do
    echo "Running: $cmd"  # Print the command being run
    output=$(eval $cmd)  # Capture the output of the command
    if [ $? -ne 0 ]; then
        echo "Command failed: $cmd"  # If command fails, print failure message
        echo "$cmd failed" | mail -s "Stress-ng Test Failed" jeremy.bell@nih.gov  # Send failure email
        exit 1  # Exit the script with an error code
    fi
    echo "Completed: $cmd"  # Print completion message
    # Send the output of the test as an email
    echo "$output" | mail -s "Stress-ng Test Completed: $cmd" jeremy.bell@nih.gov
done
