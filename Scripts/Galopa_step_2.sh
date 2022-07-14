#!/bin/bash

## This script is intended to work with the associated R Script R_MOAASR
## Tested and automated for gembases 
## Simply launch it on maestro cluster with:
## > ./2_maestro_MOAASR.sh
## author: Matthieu Haudiquet 
## date: 01/2022

for species in `cat species_list.txt`
	do
		echo $species
		for fam in $species/Pangenome_fam/*.csv
			do
				fam_name=$(basename $fam .csv)
				if [ ! -d "$species/ASR/$fam_name" ]
					then
						mkdir -p $species/ASR/$fam_name
						sbatch --output=$species/ASR/$fam_name/$fam_name.slurm --error=$species/ASR/$fam_name/$fam_name.err -p common --qos=fast -c 1 --wrap="pastml -t $species/$species.nwk --threads 1 -d $fam -s ',' --prediction_method MAP -o $species/ASR/$fam_name/$fam_name.res --work_dir $species/ASR/$fam_name/"
				fi
		done
done