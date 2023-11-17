#!/usr/bin/env bash

set -eux
set -o pipefail

cd /exports/me-lcco-aml-hpc/Leucegene_output #Output dir

module load container/singularity/3.8.0/gcc.8.3.1
module load tools/miniconda/python3.8/4.9.2

mkdir -p /exports/me-lcco-aml-hpc/singularity_dir
mkdir -p /exports/me-lcco-aml-hpc/singularity_dir/cache
mkdir -p /exports/me-lcco-aml-hpc/singularity_dir/tmp

export SINGULARITY_CACHEDIR=/exports/me-lcco-aml-hpc/singularity_dir/cache
export SINGULARITY_TMPDIR=/exports/me-lcco-aml-hpc/singularity_dir/tmp

# Settings for snakemake execution
readonly restart_times=2
readonly max_jobs=1200
readonly latency_wait=120
readonly jobs_per_sec=30
readonly singularity_args=' --containall --bind /exports:/exports,/home/jpseverens:/home/jpseverens '
readonly cluster_command='sbatch --parsable --mem={cluster.vmem} -N 1 -n {cluster.threads} --time {cluster.time} --tmp={cluster.tmp} --job-name={rule} --partition {cluster.queue}'
readonly slurm_cluster_status=/home/jpseverens/slurm-cluster-status/slurm-cluster-status.py 


function run_snakemake () {
    # Arguments
    local snakefile=$1
    local cluster_config=$2
    shift 2
    local other_arguments=$@

    snakemake -s ${snakefile} \
     --use-singularity \
     --singularity-args "${singularity_args}" \
     --printshellcmds \
     --cluster-config ${cluster_config} \
     --cluster "${cluster_command}" \
     --cluster-status ${slurm_cluster_status} \
     --singularity-prefix /exports/me-lcco-aml-hpc/singularity_dir \
     --rerun-incomplete \
     --jobs ${max_jobs} \
     --latency-wait ${latency_wait} \
     --max-jobs-per-second ${jobs_per_sec} \
     --restart-times ${restart_times} \
     --nolock \
     ${other_arguments}
}
#  \
# Add singularity to PATH
#export PATH=${PATH}:${SINGULARITY_BIN_DIR}

# Base conda environment
# If PS1 does not exist, conda crashes
PS1=
eval "$(conda shell.bash hook)"
conda activate HAMLET

# Config of the run.
CONFIG=/home/jpseverens/hamlet_expression/Leucegene_configs/1_stranded_config.yml

# Run name to be included in the PDF report
RUN_NAME='test'

# Run the HAMLET pipeline
cd /exports/me-lcco-aml-hpc/Leucegene_output
run_snakemake \
    /home/jpseverens/hamlet_expression/Snakefile \
    /home/jpseverens/hamlet_expression/slurm_cluster.yml \
    --configfile ${CONFIG}
