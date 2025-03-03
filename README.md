# hpc-test-suite

*A Benchmarking/Stress-Testing Application Suite for Linux HPC clusters/systems*

---

## Summary
- This is a collection of applications/test-cases/benchmarking/stress-testing software for Linux HPC clusters/systems. All of these can be cloned/forked and installed within your local environment (or your `/home` dir)

- It integrates with various aspects of a given cluster/system by:
  - Loading *[Lmod](https://github.com/TACC/Lmod)* modules
  - Installed with *[Spack](https://github.com/spack/spack)* and
  - Submitting *[SLURM](https://github.com/SchedMD/slurm)* jobs (via *[sbatch](https://slurm.schedmd.com/sbatch.html)* scripts)

- In an attempt to exercise multiple facets of a cluster simultaneously (you'll need to adjust various aspects of scripts to fit your needs - sbatch scripts can generally be run as shell scripts w/o the header or srun directive).

- The test suite below is comprised of administrative applications and is meant to be iterative, scalable, and contributed to by team members with varying skill sets and experience.

- If you notice missing details:  
| ⓘ NOTE: _In the spirit of m̷̈ͅị̶̉ń̴ͅȋ̵͜m̵̺̎ǔ̶̬m̵͋͜ ̸̟͊v̷͕̎i̶̮͘a̴̛̳b̶̺̔ḽ̶͐ĕ̶͙ ̸͎̎p̸̭̈ŕ̸̥ô̸̺d̷͈̓ú̶͙c̵̝͒ẗ̶̤́, we will fix it later._|
| :--- |

> [!WARNING]
> **This test suite should only be run when the cluster/system is not in production (e.g. during a planned maintenance outage).**

---

## Contents
* [Summary](#Summary)
* [Contents](#Contents)
* [Prerequisites](#Prerequisites)
* [Procedure](#Procedure)
  * [Picard Remove Duplicates](#Picard-Remove-Duplicates)
  * [Salmon Tutorial](#Salmon-Tutorial)
  * [gpu-burn](#gpu-burn)
  * [ior](#ior)
  * [mdtest](#mdtest)
  * [stress-ng](#stress-ng)
  * [OSU Micro Benchmarks](#OSU-Micro-Benchmarks)
  * [fio](#fio)
  * [cuda_memtest](#cuda_memtest)
  * [mpi-test-suite](#mpi-test-suite)
  * [ddRRd](#ddRRd)
  * [ddSSd](#ddSSd)
  * [Brain Stew](#Brain-Stew)
  * [R Package Library](#R-Package-Library)
* [Conclusion](#Conclusion)
* [See Also](#See-Also)
* [Archives](#Archives)

---

## Prerequisites
- The cluster cluster maintenance should be, for the most part, completed (*brought down, maintenance items completed, brought up, net/auth/comm verified etc. etc.*)
- Access to the NIAID GitHub infrastructure/repo
- Clone the [hpc-test-suite repo](https://github.com/fourzerosix/hpc-test-suite.git) and change into the new directory:  
   ```bash
   git clone https://github.com/fourzerosix/hpc-test-suite.git;cd hpc-test-suite
   ```

---

>[!TIP]
> - `scontrol show jobid -dd JOB_ID` command to show **running** job information  
> - `seff JOB_ID` command to show **completed** job information in SLURM  
> - `sacct -u USER_ID -s running -X --name JOB_NAME -n -o 'JobID' | xargs sacct -B -j` to print the batch script of job

---

## Procedure
### Picard Remove Duplicates
- http://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates
- *Duration: ~45 min*

This script uses Picard's MarkDuplicates tool to identify and remove duplicate reads in sequencing data. It loops through input BAM files, checks if the corresponding output file already exists, and submits individual SLURM jobs to process each file in parallel. Picard is installed via Apptainer on cluster, which the test-suite script calls.

##### Run:
   ```bash
   chmod u+x picard-remove-duplicates/cluster-picard-MarkDuplicates.sh && cp -rp ../input/ picard-remove-duplicates/ && ./picard-remove-duplicates/cluster-picard-MarkDuplicates.sh
   ```

##### Cleanup:
   ```bash
   rm -rfv picard-remove-duplicates/output/ picard-remove-duplicates/metrics/ picard-remove-duplicates/logs/
   ```

##### Sample Output:
   ```bash
   
   ```

---

### Salmon Tutorial:
- https://combine-lab.github.io/salmon/
- *Duration: ~15 min*

This runs through the [Salmon Tutorial](https://combine-lab.github.io/salmon/getting_started/#indexing-txome) - It will download the tutorial data (via `curl`) if it is not present

##### Run:
   ```bash
   ./salmon-tutorial/salmon-tutorial.sh
   ```

##### Cleanup:
   ```bash
   rm -rfv athal_index/ data/ quants/ slurm-logs/ athal.fa.gz
   ```

##### Sample Output:
   ```bash
   
   ```

---

### gpu-burn:
- https://github.com/wilicc/gpu-burn
- *Duration: ~5 minutes/server*

This script verifies that all GPUs in the cluster nodes are functioning by testing the sustained computational performance of GPUs for 5 minutes.
It does this by running a workload designed to heavily utilize GPU resources and assessing the thermal and power stability of the GPUs during continuous high usage.

##### Run:
   ```bash
   sbatch gpu-burn/cluster-gpu-burn.sbatch
   ```

##### Cleanup:
   ```bash
   rm -rfv gpu-burn/slurm-*
   ```

##### Sample Output:
   ```bash
   tail -n 12 gpu-burn/slurm-out-gpu-burn-ai-hpcgpu24-1230355.log
   ```
   ```
   Uninitted cublas
   done

   Tested 8 GPUs:
    GPU 0: OK
    GPU 1: OK
    GPU 2: OK
    GPU 3: OK
    GPU 4: OK
    GPU 5: OK
    GPU 6: OK
    GPU 7: OK
   ```

---

### ior
- *Duration: <5 min/each*
- https://github.com/hpc/ior

This script runs IOR (Interleaved Or Random) benchmarks to evaluate the I/O performance. It systematically tests different transfer and block sizes to assess how well the system handles various I/O workloads. The IOR benchmark tests the performance of the underlying file system using read/write operations with various transfer and block sizes to simulate diverse real-world workloads (e.g., small metadata-intensive writes vs. large sequential data transfers). It Utilizes MPI with OpenMPI and integrates with SLURM for workload management which tests the proper functioning of the MPI stack and SLURM scheduler. It tests the system's ability to handle parallel I/O efficiently by running processes concurrently and by varying the IOR_SEGMENTS and running on a single node. The script evaluates the ability of the node and its file system to scale with increasing workload sizes and captures potential failures in individual tests and logs them for troubleshooting, helping identify instability in the system or file system.

##### Run:
   ```bash
   sbatch ior/cluster-ior-single-node.sbatch
   ```
   ```bash
   sbatch ior/cluster-ior-distributed.sbatch
   ```

##### Cleanup:
   ```bash
   rm -rfv ior_results*
   ```

##### Sample Output:
   ```bash
   
   ```

---

### mdtest
- *Duration: <5 min*
- https://github.com/LLNL/mdtest

This script tests the metadata performance of the underlying file system on a cluster, which can reveal latency and throughput for creating, reading, and linking files and directorie as well as scalability and performance characteristics of the file system under MPI parallelism.

##### Run:
   ```bash
   sbatch mdtest/cluster-mdtest.sbatch
   ```

##### Cleanup:
   ```
   rm -rfv out/ mdtest_*
   ```

##### Sample Output:
   ```bash
   
   ```

---

### stress-ng
- *Duration*:
  - *Hare: ~60 min*  
  ~- *Tortoise: ~50 min*~
- https://github.com/ColinIanKing/stress-ng

stress-ng will stress test a computer system in various select able ways. It was designed to exercise various physical subsystems of a computer as well as the various operating system kernel interfaces. This sbatch script runs 26 separate stress tests.

##### Run:
   ```bash
   sbatch cluster-stress-ng-hare.sbatch

   ```

##### Cleanup:
   ```bash
   rm -rfv tmp-stress-ng-* stress-ng-tests-* stress-ng-* mail-job*
   ```

##### Sample Output:
   ```bash
   
   ```

---

### stressapptest
- *Duration: ~10 min/server*
- https://github.com/stressapptest/stressapptest

Stressful Application Test (or stressapptest, its unix name) is a memory interface test. It tries to maximize randomized traffic to memory from processor and I/O, with the intent of creating a realistic high load situation in order to test the existing hardware devices in a computer.

##### Run:
   ```bash
   sbatch cluster-stressapptest.sbatch
   ```

##### Cleanup:
   ```bash
   rm -rfv stressapptest_*
   ```

##### Sample Output:
   ```bash
   
   ```

---

### OSU Micro Benchmarks
- *Duration: ~1 minute*
- https://github.com/forresti/osu-micro-benchmarks
- http://mvapich.cse.ohio-state.edu/benchmarks/

This script runs 26 separate MPI-based tests. Including Point-to-Point MPI tests benchmarking latency, multi-threaded latency, multi-pair latency, multiple bandwidth / message rate test, bandwidth, bidirectional bandwidth tests - as well as Non-Blocking Collective (NBC) MPI tests benchmarking collective latency and overlap tests for various MPI collective operations - and installed with CUDA, ROCm, and OpenACC extensions to support CUDA Managed Memory.

##### Run:
   ```bash
   sbatch cluster-osumb.sbatch
   ```
##### Cleanup:
   ```bash
   rm -rfv osu_benchmarks_*
   ```

##### Sample Output:
   ```bash
   
   ```

---

## **BELOW IS A W.I.P. - belljs 2024.12.12**

---

### fio
- *Duration: ~1 minute*
- https://github.com/axboe/fio

Fio spawns a number of threads or processes doing a particular type of I/O action as specified by the user. fio takes a number of global parameters, each inherited by the thread unless otherwise parameters given to them overriding that setting is given. The typical use of fio is to write a job file matching the I/O load one wants to simulate.

##### Run:
   ```bash
   sbatch cluster-fio.sbatch
   ```
##### Cleanup:
   ```bash
   
   ```

##### Sample Output:
   ```bash
   
   ```

---

### cuda_memtest
- *Duration: ~1 minute*
- https://github.com/ComputationalRadiationPhysics/cuda_memtest

This software tests GPU memory for hardware errors and soft errors using CUDA (or OpenCL).

##### Run:
   ```bash
   sbatch cluster-cuda-memtest.sbatch
   ```
##### Cleanup:
   ```bash
   
   ```

##### Sample Output:
   ```bash
   
   ```

---

### mpi-test-suite
- *Duration: ~1 minute*
-https://github.com/open-mpi/mpi-test-suite/

The MPI-Testsuite may be run with an arbitrary number of processes. It runs a variety of P2P and Collective tests with varying datatypes and preset communicators. Each test specifies which kind of datatypes -- e.g., struct datatypes and communicators, e.g., MPI_COMM_SELF, intra-comms and the like -- it may run.

##### Run:
   ```bash
   
   ```
##### Cleanup:
   ```bash
   
   ```

##### Sample Output:
   ```bash
   
   ```

---

### ddRRd
- *Duration: ~30 minutes*
- https://github.niaid.nih.gov/rmllinux/cluster-test-suite/blob/main/ddRRd.sbatch

This script submits a SLURM job using the dd/rsync commands - it evaluates the time taken to create, transfer, and delete files of various sizes - the results are logged for performance analysis.

##### Run:
   ```bash
   sbatch ddRRd.sbatch
   ```

##### Cleanup:
   ```bash
   rm -rfv round-trip*
   ```

##### Sample Output:
   ```bash
   [belljs@ai-rmlsbatch2 dev]$ cat round-trip.txt
   File Size Creation Time   Rsync-to Time   Rsync-back Time Deletion Time
   1K       0.004235177     0.007711179     0.126994257     0.001489906
   10K      0.002858043     0.006193582     0.126574219     0.001473395
   100K     0.002605809     0.005837673     0.126184067     0.001501969
   1000K    0.005309893     0.005881315     0.125948205     0.001535772
   10000K   0.055909897     0.006248765     0.126629603     0.001470469
   100000K  0.324975832     0.006586629     0.126279827     0.001553415
   1M       0.005582264     0.005777891     0.126153891     0.001462454
   10M      0.048152431     0.006391823     0.126242717     0.001486219
   100M     0.319890390     0.006609362     0.126299975     0.001467224
   1000M    3.057990329     0.006720099     0.126672764     0.001744513
   10000M   30.567940489    0.025783280     0.126312298     0.002147850
   1G       3.062647446     0.006604433     0.126306877     0.001463556
   10G      30.505738614    0.007211760     0.126774594     0.002401192
   100G     305.061472424   0.007723441     0.126361025     0.003023190
   ```

---

### ddSSd
- *Duration: ~1 minute*
- https://github.niaid.nih.gov/rmllinux/cluster-test-suite/blob/main/brain-stew.sbatch

##### Run:
   ```bash

   ```
##### Cleanup:
   ```bash

   ```

##### Sample Output:
   ```bash
   
   ```

### Brain Stew
- *Duration: ~1 minute*
- https://github.niaid.nih.gov/rmllinux/cluster-test-suite/blob/main/brain-stew.sbatch

##### Run:
   ```bash
   sbatch ddRRd.sbatch
   ```
##### Cleanup:
   ```bash
   rm -rfv round-trip*
   ```

##### Sample Output:
   ```bash
   
   ```

---
### R Package Library:
- *Duration: <5 minutes*

This script tests all available R packages provided by the system can load individually and together, and launches around 486 R jobs on the cluster, all of which should dump individual log files in `./slurm_logs/`

##### Run:
   ```bash
   ./cluster-R-test.sh
   ```
##### Cleanup:
   ```bash
   rm -rfv tmp*;rm -rfv slurm_logs/*
   ```

---

### Globus
### ThinLinc:
- https://hpcthinlinc.niaid.nih.gov/
  - RStudio
  - BEAST
  - ChimeraX
