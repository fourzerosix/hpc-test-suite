#!/bin/bash
# Author: Dolphin Whisperer
# Email: jeremy.bell@nih.gov
# Date: 2024.12.12
# Duration: <1 min#
# Description: The script is an SBATCH job script designed to generate multiple .csv files on a cluster, each containing a specified number of rows and 100 fields per row.
# It logs both the time taken to create each file and the total execution time to the SLURM output file.
# Home: https://github.niaid.nih.gov/rmllinux/skyline-test-suite/edit/main/shine-on-you-crazy-diamond.sh

#SBATCH --job-name=GL@$$Y
#SBATCH --output=shine-on-slurm-out-%j.log
#SBATCH --time=00:33:33
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

# set hardstop defaults
DATETIME_STAMP=$(date +"%Y-%m-%dT%H%M%S")
STRT_SEC=$(date +"%s")
BASH_VERS=$BASH_VERSION
if [ ${BASH_VERS:0:1} == "4" ]; then
    IS_BASH4=1
fi

# assign default prefix string for output path
PATH_PREFIX="Testdata_"
USER_ASSIGNED=""
DFLT_N_FILES=10
N_FILES=10
N_LINES=100
CH_WIDTH=16
PATH_EXT="csv"

# parse arguments if provided
if [ "$#" -ge 1 ]; then
    N_FILES=$1
fi
if [ "$#" -ge 2 ]; then
    N_LINES=$2
fi

# start task
echo "Task at $(pwd) started $DATETIME_STAMP generating $N_FILES files"
echo "Each file will contain $N_LINES lines. Using Bash version $BASH_VERS"

# timing variables
TOTAL_START=$(date +%s)

for ((ithFile=1; ithFile <= N_FILES; ithFile++)); do
    FILE_START=$(date +%s)

    # Generate output file path
    IDX=$(printf "%08d" $ithFile)
    OUTPUT_PATH=${PATH_PREFIX}${IDX}.${PATH_EXT}

    # Remove existing file if it exists
    if [ -f $OUTPUT_PATH ]; then
        rm -f $OUTPUT_PATH
    fi

    # Create the file and write the header
    touch $OUTPUT_PATH
    echo "Creating file: $OUTPUT_PATH with $N_LINES lines"

    # Create header with 100 fields
    for ((ithField=1; ithField <= 100; ithField++)); do
        if [[ $ithField -eq 100 ]]; then
            printf "FIELD_%d\n" "$ithField" >> $OUTPUT_PATH
        else
            printf "FIELD_%d," "$ithField" >> $OUTPUT_PATH
        fi
    done

    # Write data rows
    for ((ithLine=1; ithLine <= N_LINES; ithLine++)); do
        DATETIME_STAMP=$(date +"%Y-%m-%dT%H%M%S")
        ROW=""
        for ((ithField=1; ithField <= 100; ithField++)); do
            VALUE=$(echo $((1 + RANDOM % 32767)))
            if [[ $ithField -eq 100 ]]; then
                ROW+="$VALUE\n"
            else
                ROW+="$VALUE,"
            fi
        done
        printf "%s" "$ROW" >> $OUTPUT_PATH
    done

    # File creation timing
    FILE_END=$(date +%s)
    FILE_DURATION=$((FILE_END - FILE_START))
    echo "File $OUTPUT_PATH created in $FILE_DURATION seconds"
done

# Total timing
TOTAL_END=$(date +%s)
TOTAL_DURATION=$((TOTAL_END - TOTAL_START))
echo "Task completed at $(date +"%Y-%m-%dT%H%M%S") in $TOTAL_DURATION seconds"
ls -l "${PATH_PREFIX}"*
