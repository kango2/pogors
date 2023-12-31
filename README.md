# Generate TE library using RepeatModeler
When soft masking your genome, using a taxon repeats library (eg. from Dfam) will often result in low masking percentage because the library lack the species-specific repeats for your particular species. The presence of unmasked repeats in your genome, especially in high density will impede downstream annotation. Therefore, it is crucial to generate a species-specific repeat library in such cases.

Scripts to generate custom species-specific repeats library can be found here [run_repeatmodeler.sh](https://github.com/kango2/pogors/blob/main/run_repeatmodeler.sh). It can be launched as follows.
```
export workingdir="/path/to/working_directory"
export inputgenome="/path/to/genome.fa"
export species="Species_name"
qsub -P ${PROJECT} -o ${workingdir} -v workingdir=${workingdir},inputgenome=${inputgenome},species=${species} run_repeatmodeler.sh
```
OR a one liner
```
qsub -P ${PROJECT} -o /path/to/workingdir -v workingdir=/path/to/workingdir,inputgenome=/path/to/genome.fa,species=Species_name run_repeatmodeler.sh
```
The output repeat library (location below) can be used as a custom repeats library in RepeatMasker to mask your genome, or you could concatenate this species-specific library with your taxon repeats library and use that instead.
NOTES:
1. For whatever reason, local installation of RepeatModeler will run slower than conda installation (significantly slower, possibly a bug on the software's end), it is therefore why this script uses the conda installation of RepeatModeler 2.0.4 on NCI gadi.
2. The LTR pipeline within RepeatModeler does not seem to be working, therefore it is excluded in the parameters.
3. **Output files:** `${workingdir}/database/${species}-families.fa` and `${workingdir}/database/${species}-families.stk`
