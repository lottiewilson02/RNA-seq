#!/bin/bash
#SBATCH --partition=defq       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=4      #   
#SBATCH --mem-per-cpu=4G     # in megabytes, unless unit explicitly stated
#SBATCH --error=logs/%J.err         # redirect stderr to this file
#SBATCH --output=logs/%J.out        # redirect stdout to this file
#SBATCH --mail-user=wilsoncl6@cardiff.ac.uk  # email
#SBATCH --mail-type=BEGIN,END,FAIL      # email on job start, end, and/or failur

#################################################################################
# Print Slurm Parameters to Console
#################################################################################

echo "Usable Environment Variables:"
echo "============================="
echo "hostname=$(hostname)"
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

#################################################################################
# Modulels to Load and Setup
#################################################################################

module load subread/2.0.6-abbqxcc

#export the reference directory
export $refdir=/mnt/scratch45/c21010903/jumble

# define the working directory

export $workingdir=/mnt/scratch45/c21010903

##REMEMBER: set up any directories that the software needs in this script in case 
##it is unable to do so itself

mkdir featureCounts

#################################################################################
# Main CMD
#################################################################################

list=(
        "HT-64" \
        "HT-63" \
        "HT-62" \
        "WA-61" \
        "WA-60" \
        "WA-59")

for i in ${list[@]}
do
    echo "============================="
    echo ${i} "markdup FC = running"

# Count how many genomic features are present in your sequencing reads (example 
# is gene reads, and only exons because it's RNA)

    featureCounts \
                -T ${SLURM_CPUS_PER_TASK} \
                -p \
                -F GTF \
                -t exon \
                -g ID \
                -a $refdir/Ri_AB.gff \
                -o $workingdir/featureCounts/${i}.markdup.featurecount \
                $workingdir/markdup/RiAB_markdup/${i}.markdup.bam

    echo ${i} "markdup FC = complete"

    #echo ${i} "remove duplicate FC = running"

    #featureCounts \
                #-T ${SLURM_CPUS_PER_TASK} \
                #-p \
                #-F GTF \
                #-t exon \
                #-g gene_id \
                #-a $refdir/YOUR_REFERENCE_ANNOTATION \
                #-o $workingdir/featureCounts/${i}.rmdup.featurecount \
                #$workingdir/markdup/${i}.rmdup.bam

    #echo ${i} "remove duplicate FC = complete" 
    #echo "============================="

done

#################################################################################
# End
#################################################################################