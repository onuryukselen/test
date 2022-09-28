This pipeline maps inDrop reads to selected genome (by using Tophat2), measures digital gene expression (by using ESAT) and finally creates UMI distributions table for expression analysis. 

##### Inputs:
  * Determined_fastq: output of Bcl2fastq software which has a structure as shown at below. In order to enter these files, following glob pattern need to be used: /pathtofiles/*_L00?_{R1,R2,R3}_001.fastq.gz. (Note: Asterisk part should cover sample specific region which will be used for merging reads.)
```
S1_L001_R1_001.fastq.gz    S1_L002_R1_001.fastq.gz   S1_L003_R1_001.fastq.gz   S1_L004_R1_001.fastq.gz
S1_L001_R2_001.fastq.gz    S1_L002_R2_001.fastq.gz   S1_L003_R2_001.fastq.gz   S1_L004_R2_001.fastq.gz
S1_L001_R3_001.fastq.gz    S1_L002_R3_001.fastq.gz   S1_L003_R3_001.fastq.gz   S1_L004_R3_001.fastq.gz
```

###### Reads format:
* R1 (sequence read) file 
* R2 (BC1) file. 
* R3 (BC2 + UMI) file
	* BC1 length = 8, BC2 length = 8, UMI length = 6


##### Steps:
  1. Python script (extractValidReads_V3_ps.py) is used to extract valid reads by checking cell barcode list. Determined_fastq files should be entered as input (eg. /share/SingleCellPart1/determined_fastq/*_????_{R1,R2,R3}_001.fastq.gz) Asterisk part should cover sample specific region which will be used for merging reads.
  2. Reads that are belong to same sample will be merged by checking sample name (region that covers asterisk in the input pattern of determined_fastq). 
  3. Fastq files are splitted by the desired cutoff value in order to enhance the speed of alignment.
  4. Splitted fastq files are aligned by Tophat2 and converted to bam files.
  5. Mapped reads are merged by samtools.
  6. Merged bams are sorted and indexed by samtools. 
  7. Python script (countUniqueAlignedBarcodes_fromFile.py) used to count reads aligned to a single cell for filtering purposes. 
  8. Python script (filter_lowCountBC_bam_print.py) removes cells from bam files that are below cutoff value (eg. 3000 reads per cell). 
  9. ESAT(http://garberlab.umassmed.edu/software/esat/) create UMI distributions table.
  10. Python script (cleanLowEndUmis.py) merges low count UMIs with high count UMIs and created output file (*_umiClean.txt). 

##### Outputs:

*UMI table: The output file (*_umiClean.txt) is tab separated gene/transcript vs cell_Barcode matrix filled with count data as shown at the example below.

    | gene  | ATCAATCGCGAACCGA | ACCCTCAACTCAAACA | ACTCATACCCGGAAAT |
    |-------|------------------|------------------|------------------|
    | RNF14 | 0                | 0                | 0                |
    | MZT2B | 0                | 12               | 0                |
    | SPN   | 0                | 2                | 8                |


##### Citation:

If you use DolphinNext in your research, please cite: 
Yukselen, O., Turkyilmaz, O., Ozturk, A.R. et al. DolphinNext: a distributed data processing platform for high throughput genomics. BMC Genomics 21, 310 (2020). https://doi.org/10.1186/s12864-020-6714-x
