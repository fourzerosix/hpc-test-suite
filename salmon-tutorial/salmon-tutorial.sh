#!/bin/bash

CPUS_PER_TASK=8
PARTITION=all

TMPDIR=./tmp
SLOGS=./slurm-logs
umask 0007
mkdir -p $TMPDIR $SLOGS

ml salmon/1.10.2-5pqf3j6

## Obtaining a transcriptome and building an index
srun -p ${PARTITION} -J GOGRIZ-curl-transcriptome -o $SLOGS/stdout-curl-get-transcriptome-%J.txt -e $SLOGS/stderr-curl-get-transcriptome-%J.txt \
        curl -s -S -C - ftp://ftp.ensemblgenomes.org/pub/plants/release-28/fasta/arabidopsis_thaliana/cdna/Arabidopsis_thaliana.TAIR10.28.cdna.all.fa.gz -o athal.fa.gz
# salmon index doesn't scale well, any only ocassionally uses 8 threads when specified
srun -p ${PARTITION} -c $CPUS_PER_TASK -J salmon-index -o $SLOGS/stdout-salmon-index-%J.txt -e $SLOGS/stderr-salmon-index-%J.txt \
        salmon index -p $CPUS_PER_TASK --tmpdir $TMPDIR -t athal.fa.gz -i athal_index

## Obtaining sequencing data
mkdir -p data
cd data
for i in `seq 25 40`;
do
  mkdir -p DRR0161${i};
  cd DRR0161${i};
  srun -p ${PARTITION} -J GOGRIZ-wget-seq-data -o ../../$SLOGS/stdout-wget-seq-data-%J.txt -e ../../$SLOGS/stderr-wget-seq-data-%J.txt \
        wget --quiet -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/DRR016/DRR0161${i}/DRR0161${i}_1.fastq.gz &
  srun -p ${PARTITION} -J GOGRIZ-wget-seq-data -o ../../$SLOGS/stdout-wget-seq-data-%J.txt -e ../../$SLOGS/stderr-wget-seq-data-%J.txt \
        wget --quiet -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/DRR016/DRR0161${i}/DRR0161${i}_2.fastq.gz &
  cd ..
done
cd ..
wait

## Quantifying the samples
for fn in data/DRR0161{25..40};
do
samp=`basename ${fn}`
echo "Processing sample ${samp}"
srun -p ${PARTITION} -c $CPUS_PER_TASK -J salmon-quant -o $SLOGS/stdout-salmon-quant-%J.txt -e $SLOGS/stderr-salmon-quant-%J.txt \
     salmon quant -i athal_index -l A \
         -1 ${fn}/${samp}_1.fastq.gz \
         -2 ${fn}/${samp}_2.fastq.gz \
         -p $CPUS_PER_TASK --validateMappings -o quants/${samp}_quant &
done
wait
