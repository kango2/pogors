#!/bin/bash
#PBS -l ncpus=24,mem=60GB,walltime=48:00:00,storage=gdata/if89+gdata/xl04
#PBS -N repeatmodeler
#PBS -j oe

set -ex
module use /g/data/if89/apps/modulefiles
module load RepeatModeler/2.0.4-conda

cd ${workingdir}
mkdir database
cd database
BuildDatabase -name ${species} -engine ncbi ${inputgenome}
cd ${workingdir}
RepeatModeler -database ${workingdir}/database/${species} -pa ${PBS_NCPUS} > out.log

#output repeat library will be in ${workingdir}/database named:
#${speices}-families.fa
#${species}-families.stk
#the .fa file can be fed directory into repeatmasker for soft masking, or you can concatenate it with the taxon repeats library for better repeat coverage

export RM_folder=$(ls | grep RM_) 
echo -e "cd ${workingdir}\ntar -czvf ${RM_folder}.tar.gz ${RM_folder}\nrm -rf ${RM_folder}" > ${workingdir}/cleanup.sh
chmod u+x ${workingdir}/cleanup.sh
