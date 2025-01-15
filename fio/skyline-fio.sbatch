#!/bin/bash
#SBATCH --job-name=P3R$!$T3NC3_0F_M3M0RY
#SBATCH --output=fio_cpuclock_test-%j.out
#SBATCH --error=fio_cpuclock_test-%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --partition=default

# Load the fio module
module load ml fio/3.36-63qn7zc

# Get the list of nodes in the cluster
NODELIST=$(scontrol show hostname $SLURM_NODELIST)

# Submit a job to each node
for NODE in $NODELIST; do
  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=fio-cpuclock-${NODE}
#SBATCH --output=fio-cpuclock-${NODE}-%j.out
#SBATCH --error=fio-cpuclock-${NODE}-%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --partition=default
#SBATCH --nodelist=${NODE}

module load ml fio/3.36-63qn7zc
fio --cpuclock-test
EOF

done
