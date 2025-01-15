#!/bin/bash

#SBATCH --job-name=D34D_R4BB1T5  # Job name for the batch script
#SBATCH --output=stress-ng-batch-%j.out  # Output file for the batch script
#SBATCH --error=stress-ng-batch-%j.err  # Error file for the batch script
#SBATCH --time=00:30:00  # Max runtime for all jobs
#SBATCH --partition=all  # Partition to submit to
#SBATCH --mail-type=END,FAIL  # Email notifications on job completion or failure
#SBATCH --mail-user=jeremy.bell@nih.gov  # Email to send notifications to

# Load the stress-ng module
module load stress-ng/0.18.06-qav7ybu

# Email address to send output files
EMAIL="jeremy.bell@nih.gov"

# Create an array of stress-ng commands
commands=(
    "stress-ng --all 8 --with cpu,hash,nop,vm --timeout 1m" # Run all stress tests with CPU, hash, nop, and VM stressors for 1 minute
    "stress-ng --cpu 4 --cpu-method fft --cpu-ops 10000 --metrics-brief" # Stress 4 CPUs using FFT method with 10,000 operations and brief metrics
    "stress-ng --cpu 4 --io 2 --vm 1 --vm-bytes 1G --timeout 60s" # Stress 4 CPUs, 2 IO workers, and 1 VM worker using 1GB memory for 60 seconds
    "stress-ng --cpu 4 --vm 2 --hdd 1 --fork 8 --timeout 1m --metrics" # Stress 4 CPUs, 2 VM workers, 1 HDD worker, and 8 fork processes for 1 minute
    "stress-ng --cpu 8 --cpu-ops 800000" # Stress 8 CPUs with 800,000 operations
    "stress-ng --cyclic 1 --cyclic-dist 2500 --cyclic-method clock_ns --cyclic-prio 100 --cyclic-sleep 10000 --hdd 0 -t 1m" # Cyclic stress with specific parameters for 1 minute
    "stress-ng --intmath 0 -t 1m --c-states" # Integer math stress test for 1 minute with C-states metrics
    "stress-ng --matrix -1 --tz -t 60" # Stress matrix calculations on all CPUs for 60 seconds, including thermal zone info
    "stress-ng --random 32 -x numa,hdd,key" # Random stress with 32 workers excluding NUMA, HDD, and key stressors
    "stress-ng --random 64" # Random stress with 64 workers
    "stress-ng --seq 8 --with cpu,hash,nop,vm --timeout 1m --progress" # Sequential stress on 8 workers with specific stressors for 1 minute
    "stress-ng --sequential 2 --timeout 2m --metrics" # Sequential stress on 2 workers for 2 minutes with metrics
    "stress-ng --sequential 4 --class vm --exclude bigheap,brk,stack" # Sequential VM stress on 4 workers excluding specific classes
    "stress-ng --taskset 0,2-3 --cpu 3" # Taskset stress targeting CPUs 0, 2, and 3 with 3 workers
    "stress-ng --taskset odd --cpu 32" # Taskset stress targeting odd CPUs with 32 workers
    "stress-ng --vdso 1 -t 5 --metrics" # Stress VDSO for 5 seconds with metrics
    "stress-ng --with cpu,matrix,vecmath,fp --permute 5 -t 10s" # Stress specific stressors with permutation for 10 seconds
    "stress-ng --with cpu,matrix,vecmath,fp --seq 8 -t 1m" # Sequential stress with specific stressors on 8 workers for 1 minute
)

# Log file for errors
error_log="stress-ng-errors.log"
echo "Starting stress-ng job submissions" > "$error_log"

# Loop through commands and submit each job
for i in "${!commands[@]}"; do
    command="${commands[$i]}"
    job_name="stress-ng-job-$i"
    output_file="stress-ng-$i.out"

    # Create a temporary script for the stress-ng command
    script_file="stress-ng-job-$i.sh"
    echo "#!/bin/bash" > "$script_file"
    echo "#SBATCH --job-name=$job_name" >> "$script_file"
    echo "#SBATCH --output=$output_file" >> "$script_file"
    echo "#SBATCH --mail-type=NONE" >> "$script_file"
    echo "$command > $output_file 2>&1" >> "$script_file"

    # Submit the stress-ng job
    sbatch_output=$(sbatch "$script_file" 2>&1)
    if echo "$sbatch_output" | grep -q "Submitted batch job"; then
        echo "Successfully submitted $job_name: $sbatch_output"
    else
        echo "Error submitting $job_name: $sbatch_output" >> "$error_log"
        continue
    fi

    # Create a script for sending the email
    mail_script="mail-job-$i.sh"
    echo "#!/bin/bash" > "$mail_script"
    echo "#SBATCH --job-name=mail-job-$i" >> "$mail_script"
    echo "#SBATCH --output=/dev/null" >> "$mail_script"
    echo "mail -s \"Stress-NG Job $i Results\" $EMAIL < $output_file" >> "$mail_script"

    # Submit the email job
    sbatch_output=$(sbatch "$mail_script" 2>&1)
    if echo "$sbatch_output" | grep -q "Submitted batch job"; then
        echo "Successfully submitted email job for $job_name: $sbatch_output"
    else
        echo "Error submitting email job for $job_name: $sbatch_output" >> "$error_log"
    fi
done

echo "All stress-ng jobs submitted. Check $error_log for errors."
