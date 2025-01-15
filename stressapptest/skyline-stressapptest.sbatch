#!/bin/bash
#SBATCH --job-name=T0T@L_R#C@LL       # Name of the job
#SBATCH --output=stressapptest_%j.out      # Standard output file
#SBATCH --error=stressapptest_%j.err       # Standard error file
#SBATCH --time=01:00:00                    # Maximum time limit (adjust as needed)
#SBATCH --nodes=1-8                         # Use all available nodes
#SBATCH --ntasks-per-node=1                # Number of tasks per node (adjust as needed)
#SBATCH --exclusive                        # Ensure job uses exclusive access to nodes

# Load the necessary module
module load stressapptest/1.0.9-45imemd

# Run the stressapptest command
stressapptest -s 30 -M 256 -m 8 -W

# After the job completes, send the output via email
mail -s "Stressapptest Job Output" jeremy.bell@nih.gov < stressapptest_${SLURM_JOB_ID}.out
