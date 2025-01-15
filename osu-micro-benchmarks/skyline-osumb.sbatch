#!/bin/bash
#SBATCH --job-name=oH!o
#SBATCH --output=osu_benchmarks_%j.log
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jeremy.bell@nih.gov
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=2
#SBATCH --time=00:05:00
#SBATCH --mem=16GB

# Load the required modules
module load openmpi/5.0.3-w3bgmn3
module load osu-micro-benchmarks/7.4-zdn4jjn

# List of osu benchmark tests
benchmarks=(
    #################################
    #Support for CUDA Managed Memory#
    #################################
    #The following benchmarks have been extended to evaluate performance of MPI communication
    #from and to buffers allocated using CUDA Managed Memory.
    "osu_bibw"            # Bidirectional Bandwidth Test
    "osu_bw"              # Bandwidth Test
    "osu_latency"         # Latency Test
    "osu_allgather"       # MPI_Allgather Latency Test
    "osu_allgatherv"      # MPI_Allgatherv Latency Test
    "osu_allreduce"       # MPI_Allreduce Latency Test
    "osu_alltoall"        # MPI_Alltoall Latency Test
    "osu_alltoallv"       # MPI_Alltoallv Latency Test
    "osu_bcast"           # MPI_Bcast Latency Test
    "osu_gather"          # MPI_Gather Latency Test
    "osu_gatherv"         # MPI_Gatherv Latency Test
    "osu_reduce"          # MPI_Reduce Latency Test
    "osu_reduce_scatter"  # MPI_Reduce_scatter Latency Test
    "osu_scatter"         # MPI_Scatter Latency Test
    "osu_scatterv"        # MPI_Scatterv Latency Test

    ########################################
    #Non-Blocking Collective MPI Benchmarks#
    ########################################
    "osu_iallgather"      # MPI_Iallgather Latency Test
    "osu_iallgatherv"     # MPI_Iallgatherv Latency Test
    "osu_ialltoall"       # MPI_Ialltoall Latency Test
    "osu_ialltoallv"      # MPI_Ialltoallv Latency Test
    "osu_ialltoallw"      # MPI_Ialltoallw Latency Test
    "osu_ibarrier"        # MPI_Ibarrier Latency Test
    "osu_ibcast"          # MPI_Ibcast Latency Test
    "osu_igather"         # MPI_Igather Latency Test
    "osu_igatherv"        # MPI_Igatherv Latency Test
    "osu_iscatter"        # MPI_Iscatter Latency Test
    "osu_iscatterv"       # MPI_Iscatterv Latency Test

    #################################
    #Collective OpenSHMEM Benchmarks#
    #################################
    #"osu_oshm_collect"        # OpenSHMEM Collect Latency Test
    #"osu_oshm_fcollect"       # OpenSHMEM FCollect Latency Test
    #"osu_oshm_broadcast"      # OpenSHMEM Broadcast Latency Test
    #"osu_oshm_reduce"         # OpenSHMEM Reduce Latency Test
    #"osu_oshm_barrier"        # OpenSHMEM Barrier Latency Test

    ###########################
    #Collective UPC Benchmarks#
    ###########################
    #"osu_upc_all_barrier"     # UPC Barrier Latency Test
    #"osu_upc_all_broadcast"   # UPC Broadcast Latency Test
    #"osu_upc_all_scatter"     # UPC Scatter Latency Test
    #"osu_upc_all_gather"      # UPC Gather Latency Test
    #"osu_upc_all_gather_all"  # UPC GatherAll Latency Test
    #"osu_upc_all_reduce"      # UPC Reduce Latency Test
    #"osu_upc_all_exchange"    # UPC Exchange Latency Test
)

# Disable output buffering for MPI
export OMPI_MCA_orte_base_help_aggregate=0

# Run each benchmark test
for benchmark in "${benchmarks[@]}"; do
    echo "Running $benchmark"

    # Explicitly capture output and errors
    #srun --cpus-per-task=2 mpirun -np 2 $benchmark | tee -a $SLURM_JOB_ID.log
    #srun --cpus-per-task=2 mpirun -np 2 $benchmark 2>&1 | grep -v -e "PRTE has detected that the head of the session directory tree" -e "Directory:" -e "File system type:" -e "For performance reasons" -e "If you need the temporary directory to be different" -e "This is only a warning advisory and your job will continue" -e "disable this warning in the future" | tee -a $SLURM_JOB_ID.log
    srun --cpus-per-task=2 mpirun -np 2 $benchmark 2>&1 | grep -v -e "PRTE has detected that the head of the session directory tree" \
    -e "scratch files and shared memory backing storage will be placed" \
    -e "resides on a shared file system:" \
    -e "Directory:" \
    -e "File system type:" \
    -e "For performance reasons" \
    -e "directory be located on a local file system. This can be controlled by" \
    -e "setting the system temporary directory to be used by PRTE using either" \
    -e "the TMPDIR envar or the \"prte_tmpdir_base\" MCA param." \
    -e "from the local one where prterun is running (e.g., when a login node is" \
    -e "being employed), then you can set the local temporary directory using" \
    -e "the \"prte_local_tmpdir_base\" MCA param and the one to be used on all" \
    -e "other nodes using the \"prte_remote_tmpdir_base\" param." \
    -e "This is only a warning advisory and your job will continue" \
    -e "\"prte_silence_shared_fs\" MCA param to \"1\"." | tee -a osu_benchmarks_$SLURM_JOB_ID.log
done

# Send email after job completion
#mail -s "osu benchmarks job complete" jeremy.bell@nih.gov < osu_benchmarks_$SLURM_JOB_ID.log
