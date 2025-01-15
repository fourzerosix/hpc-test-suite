#!/bin/bash

#SBATCH --job-name=3Y3_L!K3_TURTL3$  # Job name for the batch script
#SBATCH --output=stress-ng-batch-%j.out  # Output file for the batch script
#SBATCH --error=stress-ng-batch-%j.err  # Error file for the batch script
#SBATCH --time=1:00:00  # Max runtime for all jobs
#SBATCH --partition=default  # Partition to submit to
#SBATCH --mail-type=END,FAIL  # Email notifications on batch script completion or failure
#SBATCH --mail-user=jeremy.bell@nih.gov  # Email to send notifications to

# Load the stress-ng module
module load stress-ng/0.18.06-qav7ybu

# Email address to send output files
EMAIL="jeremy.bell@nih.gov"

# Create an array of stress-ng commands with comments explaining each
commands=(
    "stress-ng --all 4 --timeout 7m" # Test with all stressors enabled for 4 instances
    "stress-ng --vm 8 --vm-bytes 80% -t 7m" # Test memory stress using 8 VM workers consuming 80% of memory
    "stress-ng --cpu 0 --cpu-method all -t 7m" # CPU stress test with all available CPU methods
    "stress-ng --cpu 64 --cpu-method all --verify -t 7m --metrics-brief" # Intensive CPU stress test using 64 workers with verification enabled
    "stress-ng --iomix 2 --iomix-bytes 10% -t 7m" # Mixed I/O stress test using 2 workers with 10% of I/O bandwidth
    "stress-ng --sequential -1 -t 7m" # Sequential stress test with unlimited workers
    "stress-ng --sequential 8 --class io -t 7m --times" # Sequential stress test with 8 workers targeting I/O class
)

# Log file for errors
error_log="stress-ng-errors.log"
echo "Starting stress-ng job submissions" > "$error_log"

# Loop through commands and submit each job
for i in "${!commands[@]}"; do
    # Extract the stress-ng command and its comment
    command_and_comment="${commands[$i]}"
    comment=$(echo "$command_and_comment" | head -n 1 | sed 's/^# //')
    command=$(echo "$command_and_comment" | tail -n 1)

    job_name="stress-ng-job-$i"
    output_file="stress-ng-$i.out"

    # Create a temporary script for the stress-ng command
    script_file="stress-ng-job-$i.sh"
    echo "#!/bin/bash" > "$script_file"
    echo "#SBATCH --job-name=$job_name" >> "$script_file"
    echo "#SBATCH --output=$output_file" >> "$script_file"
    echo "#SBATCH --mail-type=NONE" >> "$script_file"
    echo "#SBATCH --exclusive" >> "$script_file"  # Ensure each job runs on a separate node
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
