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

# Transcriptome assembly using Trinity
Similar to the script in `https://github.com/kango2/pogo` but with sequencing type support (handles PE and SE) and no need to merge multi-lanes data  
Changes are:  
The tsv `trinity.filelist` now needs 5 columns for PE data and 4 columns for SE data, the columns are:
1. Unique name of the assembly output	(sample identifier)
2. Sequencing type	(either SE or PE)
3. Strandedness of RNAseq data for that sample	(for PE samples, one of RF/FR/US)(for SE samples, one of R/F/US)
4. Full path to the left (R1) fastq file	(comma separated paths if sample has multiple lanes/files) **more details below**
5. Full path to the right (R2) fastq file	(only for PE samples, comma separated paths if sample has multiple lanes/files)
  
For SE samples, make sure there are only 4 columns without any trailing whitespace or tab characters.  
If your sample is sequenced across multiple lanes, provide full paths to each lane and separate them by commas in the **4th and 5th column**. example of `trinity.filelist` with various sequencing conditions below
```
sample1_1lane	PE	RF	/path/to/sample1_R1.fq.gz	/path/to/sample1_R2.fq.gz
sample2_2lanes	PE	RF	/path/to/sample2_R1_L001.fq.gz,/path/to/sample2_R1_L002.fq.gz	/path/to/sample2_R2_L001.fq.gz,/path/to/sample2_R2_L002.fq.gz
sample3_1lane	SE	R	/path/to/sample3_R1.fq.gz
sample4_2lanes	SE	US	/path/to/sample4_R1_L001.fq.gz,/path/to/sample4_R1_L002.fq.gz
```
The command to submit jobs is also different from the pogo repository, this is the updated command
```
cat trinity.filelist | \
xargs -l bash -c 'command qsub -j oe -o /PBS/outputdir/$0.OU \
-v outputdir=/path/2/save/assemblies/Trinity,fileid=\"$0\",seqtype=\"$1\",sstype=\"$2\",leftfq=\"$3\",rightfq=\"$4\" \
runtrinityModified.sh'
```
