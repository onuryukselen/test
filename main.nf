$HOSTNAME = ""
params.outdir = 'results'  

//* params.genome_build =  ""  //* @dropdown @options:"human_hg19, human_hg38_gencode_v28, human_hg38_gencode_v34, mouse_mm10, mouse_mm10_gencode_m25, rat_rn6_refseq, mousetest_mm10, drosophila_melanogaster_dm3, custom"
//* params.run_HISAT2 =  "yes"  //* @dropdown @options:"yes","no" @show_settings:"Map_HISATs2"
//* params.run_Tophat =  "no"  //* @dropdown @options:"yes","no" @show_settings:"Map_Tophat2"
//* params.run_STAR =  "no"  //* @dropdown @options:"yes","no" @show_settings:"Map_STAR"
//* params.run_Single_Cell_Module =  "yes"  //* @dropdown @options:"yes","no" @show_settings:"filter_lowCount","ESAT"

_species = ""
_build = ""
_share = ""
_trans2gene = ""
//* autofill
if (params.genome_build == "mousetest_mm10"){
    _species = "mousetest"
    _build = "mm10"
    _trans2gene = "mm10_trans2gene_NMaug.txt"
} else if (params.genome_build == "human_hg38_gencode_v28"){
    _species = "human"
    _build = "hg38_gencode_v28"
    _trans2gene = "hg38_gencode_v28_basic_trans2gene.txt"
} else if (params.genome_build == "human_hg38_gencode_v34"){
    _species = "human"
    _build = "hg38_gencode_v34"
    _trans2gene = "hg38_gencode_v34_comprehensive_trans2gene.txt"
} else if (params.genome_build == "human_hg19"){
    _species = "human"
    _build = "hg19"
    _trans2gene = "hg19_trans2gene_NMaug.txt"
} else if (params.genome_build == "mouse_mm10"){
    _species = "mouse"
    _build = "mm10"
    _trans2gene = "mm10_trans2gene_NMaug.txt"
} else if (params.genome_build == "mouse_mm10_gencode_m25"){
    _species = "mouse"
    _build = "mm10_gencode_m25"
    _trans2gene = "mm10_gencode_m25_comprehensive_trans2gene.txt"
} else if (params.genome_build == "drosophila_melanogaster_dm3"){
    _species = "d_melanogaster"
    _build = "dm3"
    _trans2gene = "dm3_trans2gene_refseq.txt"
} else if (params.genome_build == "rat_rn6_refseq"){
    _species = "rat"
    _build = "rn6"
    _trans2gene = "rn6_trans2gene_refseq_ucsc.txt"
}
if ($HOSTNAME == "default"){
    _shareGen = "/mnt/efs/share/genome_data"
    _shareSC = "/mnt/efs/share/singleCell"
    $SINGULARITY_IMAGE = "shub://UMMS-Biocore/singularitysc"
    $SINGULARITY_OPTIONS = "--bind /mnt"
}
//* platform
if ($HOSTNAME == "garberwiki.umassmed.edu"){
    _shareGen = "/share/dolphin/genome_data"
    _shareSC = "/share/garberlab/yukseleo/singleCellPipeline"
    $SINGULARITY_IMAGE = "shub://UMMS-Biocore/singularitysc"
    $SINGULARITY_OPTIONS = "--bind /project --bind /nl --bind /share"
} else if ($HOSTNAME == "ghpcc06.umassrc.org"){
    _shareGen = "/share/data/umw_biocore/genome_data"
    _shareSC = "/project/umw_biocore/bin/singleCell"
    $TIME = 1000
    $CPU  = 1
    $MEMORY = 10
    $QUEUE = "long"
    $SINGULARITY_IMAGE = "/project/umw_biocore/singularity/UMMS-Biocore-singularitysc-master-latest.simg"
    $SINGULARITY_OPTIONS = "--bind /project --bind /nl --bind /share"
} else if ($HOSTNAME == "fs-bb7510f0"){
    _shareGen = "/mnt/efs/share/genome_data"
    _shareSC = "/mnt/efs/share/singleCell"
    $CPU  = 1
    $MEMORY = 10
    $SINGULARITY_IMAGE = "shub://UMMS-Biocore/singularitysc"
    $SINGULARITY_OPTIONS = "--bind /project --bind /nl --bind /share"
}
//* platform
if (params.genome_build && $HOSTNAME){
    params.genome ="${_shareGen}/${_species}/${_build}/${_build}.fa"
    params.gtfFilePath ="${_shareGen}/${_species}/${_build}/ucsc.gtf"
    params.genomeDir ="${_shareGen}/${_species}/${_build}/"
    params.genomeIndexPath ="${_shareGen}/${_species}/${_build}/${_build}"
    params.gene_to_transcript_mapping_file = "${_shareSC}/singleCellFiles/${_trans2gene}"
}
if ($HOSTNAME){
    params.cleanLowEndUmis_path ="${_shareSC}/singleCellScripts/cleanLowEndUmis.py"
	params.countUniqueAlignedBarcodes_fromFile_filePath ="${_shareSC}/singleCellScripts/countUniqueAlignedBarcodes_fromFile.py"
	params.ESAT_path ="${_shareSC}/singleCellScripts/esat.v0.1_09.09.16_24.18.umihack.jar"
	params.filter_lowCountBC_bam_print_py_filePath ="${_shareSC}/singleCellScripts/filter_lowCountBC_bam_split_print.py"
	params.extractValidReadsPath ="${_shareSC}/singleCellScripts/extractValidReads_V3_ps_gz.py"
	params.cellBarcodeFile = "${_shareSC}/singleCellFiles/gel_barcode1_list.txt"
	params.tophat2_path = "/usr/local/bin/dolphin-bin/tophat2_2.0.12/tophat2"
    params.hisat2_path = "/usr/local/bin/dolphin-bin/hisat2/hisat2"
    params.samtools_path = "/usr/local/bin/dolphin-bin/samtools-1.2/samtools"
    params.star_dir = "/usr/local/bin/dolphin-bin"
    params.star_path = "/usr/local/bin/dolphin-bin/STAR"
    params.mate_split = "single"
}
//*


if (!params.mate_split){params.mate_split = ""} 
if (!params.cutoff_for_reads_per_cell){params.cutoff_for_reads_per_cell = ""} 
if (!params.reads){params.reads = ""} 
if (!params.mate){params.mate = ""} 
// Stage empty file to be used as an optional input where required
ch_empty_file_1 = file("$baseDir/.emptyfiles/NO_FILE_1", hidden:true)
ch_empty_file_2 = file("$baseDir/.emptyfiles/NO_FILE_2", hidden:true)
ch_empty_file_3 = file("$baseDir/.emptyfiles/NO_FILE_3", hidden:true)
ch_empty_file_4 = file("$baseDir/.emptyfiles/NO_FILE_4", hidden:true)
ch_empty_file_5 = file("$baseDir/.emptyfiles/NO_FILE_5", hidden:true)
ch_empty_file_6 = file("$baseDir/.emptyfiles/NO_FILE_6", hidden:true)
ch_empty_file_7 = file("$baseDir/.emptyfiles/NO_FILE_7", hidden:true)
ch_empty_file_8 = file("$baseDir/.emptyfiles/NO_FILE_8", hidden:true)
ch_empty_file_9 = file("$baseDir/.emptyfiles/NO_FILE_9", hidden:true)
ch_empty_file_10 = file("$baseDir/.emptyfiles/NO_FILE_10", hidden:true)
ch_empty_file_11 = file("$baseDir/.emptyfiles/NO_FILE_11", hidden:true)

Channel.value(params.mate_split).into{g_13_mate0_g_101;g_13_mate0_g80_0;g_13_mate1_g80_3;g_13_mate0_g87_3;g_13_mate0_g103_5}
Channel.value(params.cutoff_for_reads_per_cell).into{g_118_cutoff2_g125_90;g_118_cutoff3_g125_91;g_118_cutoff2_g126_90;g_118_cutoff3_g126_91;g_118_cutoff2_g127_90;g_118_cutoff3_g127_91}
if (params.reads){
Channel
	.fromFilePairs( params.reads , size: params.mate == "single" ? 1 : params.mate == "pair" ? 2 : params.mate == "triple" ? 3 : params.mate == "quadruple" ? 4 : -1 )
	.ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
	.set{g_120_reads0_g_119}
 } else {  
	g_120_reads0_g_119 = Channel.empty()
 }

Channel.value(params.mate).set{g_121_mate1_g_119}

//* params.extractValidReadsPath =  ""  //* @input
//* params.cellBarcodeFile =  ""  //* @input


//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 1440
    $CPU  = 1
    $MEMORY = 5
    $QUEUE = "long"
}
//*

process extractValidReads {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /validfastq\/.*$/) "valid_fastq/$filename"}
input:
 set val(name), file(reads) from g_120_reads0_g_119
 val mate from g_121_mate1_g_119

output:
 set val(name), file("validfastq/*")  into g_119_valid_fastq01_g_101
 file "extractValid_${name}.tsv"  into g_119_outFileTSV10_g_128
 val "extractValid"  into g_119_name21_g_128

errorStrategy 'retry'
maxRetries 1

script:
fastq1 = reads.toString().split(' ')[0]
chunkSize = params.extractValidReads.chunkSize
"""
mkdir -p validfastq 
echo -e "Sample\\tTotal Reads\\tValid Reads" > extractValid_${name}.tsv
if [ "${mate}" == "single" ]; then
	lines=\$(cat ${fastq1}|wc -l)
	count=\$((\$lines / 4))
	echo -e "${name}\\t\$count\\t\$count" >> extractValid_${name}.tsv
    mv $reads validfastq/.
elif [ "${mate}" == "triple" ]; then
    python ${params.extractValidReadsPath} -i ${fastq1} -o ${name} -d validfastq -b ${params.cellBarcodeFile} -u 8 -c 100000 > extractValid.log
	grep -A 2 "sample" extractValid.log | grep -v "sample"  | cut  -f1-3 >> extractValid_${name}.tsv
	
fi
"""

}


process Merge_TSV_Files {

input:
 file tsv from g_119_outFileTSV10_g_128.collect()
 val outputFileName from g_119_name21_g_128.collect()

output:
 file "${name}.tsv"  into g_128_outputFileTSV03_g_122

errorStrategy 'retry'
maxRetries 3

script:
name = outputFileName[0]
"""    
awk 'FNR==1 && NR!=1 {  getline; } 1 {print} ' *.tsv > ${name}.tsv
"""
}

//* params.run_Split_Fastq =  "no"  //* @dropdown @options:"yes","no" @show_settings:"SplitFastq" @description:"Splits Fastq files before aligning with Star, Hisat2 or Tophat2 to speed up the process. However, it will require more disk space."
readsPerFile = params.SplitFastq.readsPerFile
//Since splitFastq operator requires flat file structure, first convert grouped structure to flat, execute splitFastq, and then return back to original grouped structure
//.map(flatPairsClosure).splitFastq(splitFastqParams).map(groupPairsClosure)

//Mapping grouped read structure to flat structure
flatPairsClosure = {row -> if(row[1] instanceof Collection) {
        if (row[1][1]){
            tuple(row[0], file(row[1][0]), file(row[1][1]))
        } else {
            tuple(row[0], file(row[1][0]))
        }
    } else {
        tuple(row[0], file(row[1]))
    }
}

//Mapping flat read structure to grouped read structure
groupPairsClosure = {row -> tuple(row[0], (row[2]) ? [file(row[1]), file(row[2])] : [file(row[1])])}

// if mate of split process different than rest of the pipeline, use "mate_split" as input parameter. Otherwise use default "mate" as input parameter
mateParamName = (params.mate_split) ? "mate_split" : "mate"
splitFastqParams = ""
if (params[mateParamName] != "pair"){
    splitFastqParams = [by: readsPerFile, file:true]
}else {
    splitFastqParams = [by: readsPerFile, pe:true, file:true]
}

//* autofill
//* platform
//* platform
//* autofill
if (!(params.run_Split_Fastq == "yes")){
g_119_valid_fastq01_g_101.into{g_101_reads01_g80_0; g_101_reads01_g87_3; g_101_reads01_g103_5}
} else {


process SplitFastq {

input:
 val mate from g_13_mate0_g_101
 set val(name), file(reads) from g_119_valid_fastq01_g_101.map(flatPairsClosure).splitFastq(splitFastqParams).map(groupPairsClosure)

output:
 set val(name), file("split/*q")  into g_101_reads01_g80_0, g_101_reads01_g87_3, g_101_reads01_g103_5

errorStrategy 'retry'
maxRetries 3

when:
params.run_Split_Fastq == "yes"

script:
"""    
mkdir -p split
mv ${reads} split/.
"""
}
}


params_STAR = params.STAR_Module_Map_STAR.params_STAR
//* params.star_path =  ""  //* @input
//* params.samtools_path =  ""  //* @input 
//* params.genomeDir =  ""  //* @input

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 3
    $MEMORY = 32
}
//* platform
//* platform
//* autofill

process STAR_Module_Map_STAR {

input:
 val mate from g_13_mate0_g103_5
 set val(name), file(reads) from g_101_reads01_g103_5

output:
 set val(name), file("${newName}Log.final.out")  into g103_5_outputFileOut00_g103_1
 set val(name), file("${newName}.flagstat.txt")  into g103_5_outputFileTxt11
 set val(name), file("${newName}Log.out")  into g103_5_logOut21_g103_1
 set val(name), file("${newName}.bam")  into g103_5_mapped_reads30_g103_2
 set val(name), file("${newName}SJ.out.tab")  into g103_5_outputFileTab43_g103_1
 set val(name), file("${newName}Log.progress.out")  into g103_5_progressOut52_g103_1
 set val(name), file("${newName}Aligned.toTranscriptome.out.bam") optional true  into g103_5_transcriptome_bam60_g103_13

errorStrategy 'retry'
maxRetries 3

when:
(params.run_STAR && (params.run_STAR == "yes")) || !params.run_STAR

script:
nameAll = reads.toString()
nameArray = nameAll.split(' ')

if (nameAll.contains('.gz')) {
    newName =  nameArray[0] - ~/(\.fastq.gz)?(\.fq.gz)?$/
    file =  nameAll - '.gz' - '.gz'
    runGzip = "ls *.gz | xargs -i echo gzip -df {} | sh"
} else {
    newName =  nameArray[0] - ~/(\.fastq)?(\.fq)?$/
    file =  nameAll 
    runGzip = ''
}

"""
$runGzip
${params.star_path} ${params_STAR}  --genomeDir ${params.genomeDir} --readFilesIn $file --outFileNamePrefix ${newName}
if [ ! -e "${newName}Aligned.toTranscriptome.out.bam" -a -e "${newName}Aligned.toTranscriptome.out.sam" ] ; then
    ${params.samtools_path} view -S -b ${newName}Aligned.toTranscriptome.out.sam > ${newName}Aligned.toTranscriptome.out.bam
elif [ ! -e "${newName}Aligned.out.bam" -a -e "${newName}Aligned.out.sam" ] ; then
    ${params.samtools_path} view -S -b ${newName}Aligned.out.sam > ${newName}Aligned.out.bam
fi
rm -rf *.sam
if [ -e "${newName}Aligned.sortedByCoord.out.bam" ] ; then
    mv ${newName}Aligned.sortedByCoord.out.bam ${newName}.bam
elif [ -e "${newName}Aligned.out.bam" ] ; then
    mv ${newName}Aligned.out.bam ${newName}.bam
fi

${params.samtools_path} flagstat ${newName}.bam > ${newName}.flagstat.txt
"""

}

//* params.samtools_path =  ""  //* @input

//* autofill
//* platform
//* platform
//* autofill

process STAR_Module_merge_transcriptome_bam {

input:
 set val(oldname), file(bamfiles) from g103_5_transcriptome_bam60_g103_13.groupTuple()

output:
 set val(oldname), file("${oldname}.bam")  into g103_13_merged_bams00
 set val(oldname), file("*_sorted*bai")  into g103_13_bam_index11
 set val(oldname), file("*_sorted*bam")  into g103_13_sorted_bam22

errorStrategy 'retry'
maxRetries 3

shell:
'''
num=$(echo "!{bamfiles.join(" ")}" | awk -F" " '{print NF-1}')
if [ "${num}" -gt 0 ]; then
    !{params.samtools_path} merge !{oldname}.bam !{bamfiles.join(" ")} && !{params.samtools_path} sort -O bam -T !{oldname} -o !{oldname}_sorted.bam !{oldname}.bam && !{params.samtools_path} index !{oldname}_sorted.bam
else
    mv !{bamfiles.join(" ")} !{oldname}.bam 2>/dev/null || true
    !{params.samtools_path} sort  -T !{oldname} -O bam -o !{oldname}_sorted.bam !{oldname}.bam && !{params.samtools_path} index !{oldname}_sorted.bam
fi
'''
}

//* params.samtools_path =  ""  //* @input

//* autofill
//* platform
//* platform
//* autofill

process STAR_Module_Merge_Bam {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_sorted.*bai$/) "sorted_bam_star/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_sorted.*bam$/) "sorted_bam_star/$filename"}
input:
 set val(oldname), file(bamfiles) from g103_5_mapped_reads30_g103_2.groupTuple()

output:
 set val(oldname), file("${oldname}.bam")  into g103_2_merged_bams00
 set val(oldname), file("*_sorted*bai")  into g103_2_bam_index11
 set val(oldname), file("*_sorted*bam")  into g103_2_sorted_bam20_g127_92

errorStrategy 'retry'
maxRetries 6

shell:
'''
num=$(echo "!{bamfiles.join(" ")}" | awk -F" " '{print NF-1}')
if [ "${num}" -gt 0 ]; then
    !{params.samtools_path} merge !{oldname}.bam !{bamfiles.join(" ")} && !{params.samtools_path} sort -O bam -T !{oldname} -o !{oldname}_sorted.bam !{oldname}.bam && !{params.samtools_path} index !{oldname}_sorted.bam
else
    mv !{bamfiles.join(" ")} !{oldname}.bam 2>/dev/null || true
    !{params.samtools_path} sort  -T !{oldname} -O bam -o !{oldname}_sorted.bam !{oldname}.bam && !{params.samtools_path} index !{oldname}_sorted.bam
fi
'''
}

//* params.samtools_path =  ""  //* @input

//* autofill
//* platform
//* platform
//* autofill

process Single_Cell_Module_STAR_samtools_sort_index {

input:
 set val(name), file(bam) from g103_2_sorted_bam20_g127_92

output:
 set val(name), file("bam/*.bam")  into g127_92_bam_file00_g127_90
 set val(name), file("bam/*.bai")  into g127_92_bam_index11_g127_90

errorStrategy 'retry'
maxRetries 3

script:
samtools_sort_parameters = params.Single_Cell_Module_STAR_samtools_sort_index.samtools_sort_parameters
nameAll = bam.toString()
if (nameAll.contains('_sorted.bam')) {
    runSamtools = "samtools index " + bam 
} else {
    runSamtools = params.samtools_path + " sort ${samtools_sort_parameters} -T ${name} -o " + name +"_sorted.bam " + bam +" && " + params.samtools_path + " index " + name + "_sorted.bam "
}
"""
$runSamtools
mkdir -p bam && mv *_sorted.ba* bam/.
"""

}


process STAR_Module_STAR_Summary {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.(out|tab)$/) "star/$filename"}
input:
 set val(name), file(alignSum) from g103_5_outputFileOut00_g103_1.groupTuple()
 set val(name), file(LogOut) from g103_5_logOut21_g103_1.groupTuple()
 set val(name), file(progressOut) from g103_5_progressOut52_g103_1.groupTuple()
 set val(name), file(TabOut) from g103_5_outputFileTab43_g103_1.groupTuple()

output:
 file "*.tsv"  into g103_1_outputFile00_g103_11
 set "*.{out,tab}"  into g103_1_logOut11
 val "star_alignment_sum"  into g103_1_name21_g103_11

errorStrategy 'retry'
maxRetries 3

shell:
'''
#!/usr/bin/env perl
use List::Util qw[min max];
use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage; 
use Data::Dumper;

my %tsv;
my @headers = ();
my $name = "!{name}";

# merge output files 
`cat !{alignSum} >${name}_Merged_Log.final.out`;
`cat !{LogOut} >${name}_Merged_Log.out`;
`cat !{progressOut} >${name}_Merged_Log.progress.out`;
`cat !{TabOut} >${name}_Merged_SJ.out.tab`;

alteredAligned();

my @keys = keys %tsv;
my $summary = "$name"."_star_sum.tsv";
my $header_string = join("\\t", @headers);
`echo "$header_string" > $summary`;
foreach my $key (@keys){
	my $values = join("\\t", @{ $tsv{$key} });
	`echo "$values" >> $summary`;
}


sub alteredAligned
{
	my @files = qw(!{alignSum});
	my $multimappedSum;
	my $alignedSum;
	my $inputCountSum;
	push(@headers, "Sample");
    push(@headers, "Total Reads");
	push(@headers, "Multimapped Reads Aligned (STAR)");
	push(@headers, "Unique Reads Aligned (STAR)");
	foreach my $file (@files){
		my $multimapped;
		my $aligned;
		my $inputCount;
		chomp($inputCount = `cat $file | grep 'Number of input reads' | awk '{sum+=\\$6} END {print sum}'`);
		chomp($aligned = `cat $file | grep 'Uniquely mapped reads number' | awk '{sum+=\\$6} END {print sum}'`);
		chomp($multimapped = `cat $file | grep 'Number of reads mapped to multiple loci' | awk '{sum+=\\$9} END {print sum}'`);
		$multimappedSum += int($multimapped);
        $alignedSum += int($aligned);
        $inputCountSum += int($inputCount);
	}
	$tsv{$name} = [$name, $inputCountSum];
	push(@{$tsv{$name}}, $multimappedSum);
	push(@{$tsv{$name}}, $alignedSum);
}
'''

}


process STAR_Module_merge_tsv_files_with_same_header {

input:
 file tsv from g103_1_outputFile00_g103_11.collect()
 val outputFileName from g103_1_name21_g103_11.collect()

output:
 file "${name}.tsv"  into g103_11_outputFileTSV00_g_122

errorStrategy 'retry'
maxRetries 3

script:
name = outputFileName[0]
"""    
awk 'FNR==1 && NR!=1 {  getline; } 1 {print} ' *.tsv > ${name}.tsv
"""
}

HISAT2_parameters = params.HISAT2_Module_Map_HISAT2.HISAT2_parameters
//* params.genomeIndexPath =  ""  //* @input
//* params.hisat2_path =  ""  //* @input

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 3
    $MEMORY = 32
}
//* platform
//* platform
//* autofill

process HISAT2_Module_Map_HISAT2 {

input:
 val mate from g_13_mate0_g87_3
 set val(name), file(reads) from g_101_reads01_g87_3

output:
 set val(name), file("${newName}.bam")  into g87_3_mapped_reads00_g87_1
 set val(name), file("${newName}.align_summary.txt")  into g87_3_outputFileTxt10_g87_2
 set val(name), file("${newName}.flagstat.txt")  into g87_3_outputFileOut22

when:
(params.run_HISAT2 && (params.run_HISAT2 == "yes")) || !params.run_HISAT2

script:
nameAll = reads.toString()
nameArray = nameAll.split(' ')
def file2;

if (nameAll.contains('.gz')) {
    newName =  nameArray[0] - ~/(\.fastq.gz)?(\.fq.gz)?$/
    file1 =  nameArray[0] - '.gz' 
    if (mate == "pair") {file2 =  nameArray[1] - '.gz'}
    runGzip = "ls *.gz | xargs -i echo gzip -df {} | sh"
} else {
    newName =  nameArray[0] - ~/(\.fastq)?(\.fq)?$/
    file1 =  nameArray[0]
    if (mate == "pair") {file2 =  nameArray[1]}
    runGzip = ''
}

"""
$runGzip
if [ "${mate}" == "pair" ]; then
    ${params.hisat2_path} ${HISAT2_parameters} -x ${params.genomeIndexPath} -1 ${file1} -2 ${file2} -S ${newName}.sam &> ${newName}.align_summary.txt
else
    ${params.hisat2_path} ${HISAT2_parameters} -x ${params.genomeIndexPath} -U ${file1} -S ${newName}.sam &> ${newName}.align_summary.txt
fi
samtools view -bS ${newName}.sam > ${newName}.bam
samtools flagstat ${newName}.bam > ${newName}.flagstat.txt
"""
}

//* params.samtools_path =  ""  //* @input

//* autofill
//* platform
//* platform
//* autofill

process HISAT2_Module_Merge_Bam {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_sorted.*bai$/) "sorted_bam_hisat2/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_sorted.*bam$/) "sorted_bam_hisat2/$filename"}
input:
 set val(oldname), file(bamfiles) from g87_3_mapped_reads00_g87_1.groupTuple()

output:
 set val(oldname), file("${oldname}.bam")  into g87_1_merged_bams00
 set val(oldname), file("*_sorted*bai")  into g87_1_bam_index11
 set val(oldname), file("*_sorted*bam")  into g87_1_sorted_bam20_g126_92

errorStrategy 'retry'
maxRetries 6

shell:
'''
num=$(echo "!{bamfiles.join(" ")}" | awk -F" " '{print NF-1}')
if [ "${num}" -gt 0 ]; then
    !{params.samtools_path} merge !{oldname}.bam !{bamfiles.join(" ")} && !{params.samtools_path} sort -O bam -T !{oldname} -o !{oldname}_sorted.bam !{oldname}.bam && !{params.samtools_path} index !{oldname}_sorted.bam
else
    mv !{bamfiles.join(" ")} !{oldname}.bam 2>/dev/null || true
    !{params.samtools_path} sort  -T !{oldname} -O bam -o !{oldname}_sorted.bam !{oldname}.bam && !{params.samtools_path} index !{oldname}_sorted.bam
fi
'''
}

//* params.samtools_path =  ""  //* @input

//* autofill
//* platform
//* platform
//* autofill

process Single_Cell_Module_Hisat2_samtools_sort_index {

input:
 set val(name), file(bam) from g87_1_sorted_bam20_g126_92

output:
 set val(name), file("bam/*.bam")  into g126_92_bam_file00_g126_90
 set val(name), file("bam/*.bai")  into g126_92_bam_index11_g126_90

errorStrategy 'retry'
maxRetries 3

script:
samtools_sort_parameters = params.Single_Cell_Module_Hisat2_samtools_sort_index.samtools_sort_parameters
nameAll = bam.toString()
if (nameAll.contains('_sorted.bam')) {
    runSamtools = "samtools index " + bam 
} else {
    runSamtools = params.samtools_path + " sort ${samtools_sort_parameters} -T ${name} -o " + name +"_sorted.bam " + bam +" && " + params.samtools_path + " index " + name + "_sorted.bam "
}
"""
$runSamtools
mkdir -p bam && mv *_sorted.ba* bam/.
"""

}


process HISAT2_Module_HISAT2_Summary {

input:
 set val(name), file(alignSum) from g87_3_outputFileTxt10_g87_2.groupTuple()

output:
 file "*.tsv"  into g87_2_outputFile02_g_122
 val "hisat2_alignment_sum"  into g87_2_name11

shell:
'''
#!/usr/bin/env perl
use List::Util qw[min max];
use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage; 
use Data::Dumper;

my %tsv;
my @headers = ();
my $name = "!{name}";


alteredAligned();

my @keys = keys %tsv;
my $summary = "$name"."_hisat_sum.tsv";
my $header_string = join("\\t", @headers);
`echo "$header_string" > $summary`;
foreach my $key (@keys){
	my $values = join("\\t", @{ $tsv{$key} });
	`echo "$values" >> $summary`;
}


sub alteredAligned
{
	my @files = qw(!{alignSum});
	my $multimappedSum;
	my $alignedSum;
	my $inputCountSum;
	push(@headers, "Sample");
    push(@headers, "Total Reads");
	push(@headers, "Multimapped Reads Aligned (HISAT2)");
	push(@headers, "Unique Reads Aligned (HISAT2)");
	foreach my $file (@files){
		my $multimapped;
		my $aligned;
		my $inputCount;
		chomp($inputCount = `cat $file | grep 'reads; of these:' | awk '{sum+=\\$1} END {print sum}'`);
		chomp($aligned = `cat $file | grep 'aligned.*exactly 1 time' | awk '{sum+=\\$1} END {print sum}'`);
		chomp($multimapped = `cat $file | grep 'aligned.*>1 times' | awk '{sum+=\\$1} END {print sum}'`);
		$multimappedSum += int($multimapped);
        $alignedSum += int($aligned);
        $inputCountSum += int($inputCount);
	}
	$tsv{$name} = [$name, $inputCountSum];
	push(@{$tsv{$name}}, $multimappedSum);
	push(@{$tsv{$name}}, $alignedSum);
}
'''

}

params_tophat = params.Tophat2_Module_Map_Tophat2.params_tophat
//* params.genomeIndexPath =  ""  //* @input
//* params.gtfFilePath =  ""  //* @input
//* params.tophat2_path =  ""  //* @input

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 3
    $MEMORY = 24
}
//* platform
//* platform
//* autofill

process Tophat2_Module_Map_Tophat2 {

input:
 val mate from g_13_mate0_g80_0
 set val(name), file(reads) from g_101_reads01_g80_0

output:
 set val(name), file("${newName}.bam")  into g80_0_mapped_reads00_g80_4
 set val(name), file("${newName}_unmapped.bam")  into g80_0_unmapped_reads11
 set val(name), file("${newName}_align_summary.txt")  into g80_0_summary20_g80_3

errorStrategy 'retry'
maxRetries 6

when:
(params.run_Tophat && (params.run_Tophat == "yes")) || !params.run_Tophat

script:
nameAll = reads.toString()
nameArray = nameAll.split(' ')

if (nameAll.contains('.gz')) {
    newName =  nameArray[0] - ~/(\.fastq.gz)?(\.fq.gz)?$/
    file =  nameAll - '.gz' - '.gz'
    runGzip = "ls *.gz | xargs -i echo gzip -df {} | sh"
} else {
    newName =  nameArray[0] - ~/(\.fastq)?(\.fq)?$/
    file =  nameAll 
    runGzip = ''
}

"""
$runGzip
if [ "${mate}" == "pair" ]; then
    tophat2 ${params_tophat}  --keep-tmp -G ${params.gtfFilePath} -o . ${params.genomeIndexPath} $file
else
    tophat2 ${params_tophat}  --keep-tmp -G ${params.gtfFilePath} -o . ${params.genomeIndexPath} $file
fi

if [ -f unmapped.bam ]; then
    mv unmapped.bam ${newName}_unmapped.bam
else
    touch ${newName}_unmapped.bam
fi

mv accepted_hits.bam ${newName}.bam
mv align_summary.txt ${newName}_align_summary.txt
"""
}

//* autofill
//* platform
//* platform
//* autofill

process Tophat2_Module_Merge_Tophat_Summary {

input:
 set val(name), file(alignSum) from g80_0_summary20_g80_3.groupTuple()
 val mate from g_13_mate1_g80_3

output:
 set val(name), file("${name}_tophat_sum.tsv")  into g80_3_report04_g_122
 val "tophat2_alignment_sum"  into g80_3_name11

errorStrategy 'retry'
maxRetries 3

shell:
'''
#!/usr/bin/env perl
use List::Util qw[min max];
use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage; 
use Data::Dumper;

my %tsv;
my @headers = ();
my $name = "!{name}";

alteredAligned();

my @keys = keys %tsv;
my $summary = "$name"."_tophat_sum.tsv";
my $header_string = join("\\t", @headers);
`echo "$header_string" > $summary`;
foreach my $key (@keys){
	my $values = join("\\t", @{ $tsv{$key} });
	`echo "$values" >> $summary`;
}


sub alteredAligned
{
	my @files = qw(!{alignSum});
	my $multimappedSum;
	my $alignedSum;
	my $inputCountSum;
	push(@headers, "Sample");
    push(@headers, "Total Reads");
	push(@headers, "Multimapped Reads Aligned (Tophat2)");
	push(@headers, "Unique Reads Aligned (Tophat2)");
	foreach my $file (@files){
		my $multimapped;
		my $aligned;
		my $inputCount;
		chomp($aligned = `cat $file | grep 'Aligned pairs:' | awk '{sum=\\$3} END {print sum}'`);
		if ($aligned eq "") { # then it is single-end
		        chomp($inputCount = `cat $file | grep 'Input' | awk '{sum=\\$3} END {print sum}'`);
				chomp($aligned = `cat $file | grep 'Mapped' | awk '{sum=\\$3} END {print sum}'`);
				chomp($multimapped = `cat $file | grep 'multiple alignments' | awk '{sum+=\\$3} END {print sum}'`);
			}else{ # continue to pair end
			    chomp($inputCount = `cat $file | grep 'Input' | awk '{sum=\\$3} END {print sum}'`);
				chomp($multimapped = `cat $file | grep -A 1 'Aligned pairs:' | awk 'NR % 3 == 2 {sum+=\\$3} END {print sum}'`);
			}
        $multimappedSum += int($multimapped);
        $alignedSum += (int($aligned) - int($multimapped));
        $inputCountSum += int($inputCount);
        if ($alignedSum < 0){
            $alignedSum = 0;
        }
	}
	$tsv{$name} = [$name, $inputCountSum];
	push(@{$tsv{$name}}, $multimappedSum);
	push(@{$tsv{$name}}, $alignedSum);
}
'''

}

//* params.samtools_path =  ""  //* @input

//* autofill
//* platform
//* platform
//* autofill

process Tophat2_Module_Merge_Bam {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_sorted.*bai$/) "sorted_bam_tophat2/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_sorted.*bam$/) "sorted_bam_tophat2/$filename"}
input:
 set val(oldname), file(bamfiles) from g80_0_mapped_reads00_g80_4.groupTuple()

output:
 set val(oldname), file("${oldname}.bam")  into g80_4_merged_bams00
 set val(oldname), file("*_sorted*bai")  into g80_4_bam_index11
 set val(oldname), file("*_sorted*bam")  into g80_4_sorted_bam20_g125_92

errorStrategy 'retry'
maxRetries 6

shell:
'''
num=$(echo "!{bamfiles.join(" ")}" | awk -F" " '{print NF-1}')
if [ "${num}" -gt 0 ]; then
    !{params.samtools_path} merge !{oldname}.bam !{bamfiles.join(" ")} && !{params.samtools_path} sort -O bam -T !{oldname} -o !{oldname}_sorted.bam !{oldname}.bam && !{params.samtools_path} index !{oldname}_sorted.bam
else
    mv !{bamfiles.join(" ")} !{oldname}.bam 2>/dev/null || true
    !{params.samtools_path} sort  -T !{oldname} -O bam -o !{oldname}_sorted.bam !{oldname}.bam && !{params.samtools_path} index !{oldname}_sorted.bam
fi
'''
}

//* params.samtools_path =  ""  //* @input

//* autofill
//* platform
//* platform
//* autofill

process Single_Cell_Module_Tophat2_samtools_sort_index {

input:
 set val(name), file(bam) from g80_4_sorted_bam20_g125_92

output:
 set val(name), file("bam/*.bam")  into g125_92_bam_file00_g125_90
 set val(name), file("bam/*.bai")  into g125_92_bam_index11_g125_90

errorStrategy 'retry'
maxRetries 3

script:
samtools_sort_parameters = params.Single_Cell_Module_Tophat2_samtools_sort_index.samtools_sort_parameters
nameAll = bam.toString()
if (nameAll.contains('_sorted.bam')) {
    runSamtools = "samtools index " + bam 
} else {
    runSamtools = params.samtools_path + " sort ${samtools_sort_parameters} -T ${name} -o " + name +"_sorted.bam " + bam +" && " + params.samtools_path + " index " + name + "_sorted.bam "
}
"""
$runSamtools
mkdir -p bam && mv *_sorted.ba* bam/.
"""

}

//* params.countUniqueAlignedBarcodes_fromFile_filePath =  ""  //* @input

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 500
    $CPU  = 1
    $MEMORY = 8
    $QUEUE = "long"
}
//*
if (!((params.run_Single_Cell_Module && (params.run_Single_Cell_Module == "yes")) || !params.run_Single_Cell_Module)){
g125_92_bam_file00_g125_90.set{g125_90_sorted_bam00_g125_91}
g125_92_bam_index11_g125_90.set{g125_90_bam_index12_g125_91}
g125_90_count_file21_g125_91 = Channel.empty()
} else {


process Single_Cell_Module_Tophat2_Count_cells {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_count.txt$/) "cell_counts_after_tophat2/$filename"}
input:
 set val(oldname), file(sorted_bams) from g125_92_bam_file00_g125_90
 set val(oldname), file(bams_index) from g125_92_bam_index11_g125_90
 val cutoff_reads_per_cell from g_118_cutoff2_g125_90

output:
 set val(oldname), file("bam/*.bam")  into g125_90_sorted_bam00_g125_91
 set val(oldname), file("bam/*.bam.bai")  into g125_90_bam_index12_g125_91
 set val(oldname), file("*_count.txt")  into g125_90_count_file21_g125_91

errorStrategy 'retry'

when:
(params.run_Single_Cell_Module && (params.run_Single_Cell_Module == "yes")) || !params.run_Single_Cell_Module

script:
"""
find  -name "*.bam" > filelist.txt
python ${params.countUniqueAlignedBarcodes_fromFile_filePath} -i filelist.txt -m ${cutoff_reads_per_cell} -o ${oldname}_count.txt
mkdir bam
mv $sorted_bams bam/.
mv $bams_index bam/.
"""
}
}


//* params.filter_lowCountBC_bam_print_py_filePath =  ""  //* @input
maxCellsForTmpFile = params.Single_Cell_Module_Tophat2_filter_lowCount.maxCellsForTmpFile

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 500
    $CPU  = 1
    $MEMORY = 8
    $QUEUE = "long"
}
//*

process Single_Cell_Module_Tophat2_filter_lowCount {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${name}_filtered_.*.bam$/) "filtered_bam_after_tophat2/$filename"}
input:
 set val(oldname), file(sorted_bams) from g125_90_sorted_bam00_g125_91
 set val(name), file(count_file) from g125_90_count_file21_g125_91
 set val(oldname), file(bam_index) from g125_90_bam_index12_g125_91
 val cutoff_for_filter from g_118_cutoff3_g125_91

output:
 set val(name), file("${name}_filtered_*.bam") optional true  into g125_91_filtered_bam00_g125_87

errorStrategy 'retry'
maxRetries 3

script:
"""
python ${params.filter_lowCountBC_bam_print_py_filePath} -i ${sorted_bams} -b ${name}_count.txt -o ${name}_filtered.bam -n ${cutoff_for_filter} -c ${maxCellsForTmpFile}
"""
}

esat_parameters = params.Single_Cell_Module_Tophat2_ESAT.esat_parameters
esat_RAM = params.Single_Cell_Module_Tophat2_ESAT.esat_RAM
//* params.ESAT_path =  ""  //* @input
//* params.gene_to_transcript_mapping_file =  ""  //* @input


//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 40
}
//* platform
//* platform
//* autofill

process Single_Cell_Module_Tophat2_ESAT {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.(txt|log)$/) "esat_after_tophat2/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*umi.distributions.txt$/) "esat_after_tophat2/$filename"}
input:
 set val(name), file(filtered_bam) from g125_91_filtered_bam00_g125_87.transpose()

output:
 file "*.{txt,log}"  into g125_87_outputFileTxt00
 set val(name), file("*umi.distributions.txt") optional true  into g125_87_UMI_distributions10_g125_88
 set val(name), file("${namePrefix}_esat.log")  into g125_87_log_file20_g125_93

errorStrategy 'retry'
maxRetries 1

script:
nameAll = filtered_bam.toString()
namePrefix = nameAll - ".bam"
"""    
find  -name "*.bam" | awk '{print "${namePrefix}\t"\$1 }' > ${namePrefix}_filelist.txt
java -Xmx${esat_RAM}g -jar ${params.ESAT_path} -alignments ${namePrefix}_filelist.txt -out ${namePrefix}_esat.txt -geneMapping ${params.gene_to_transcript_mapping_file} ${esat_parameters} > ${namePrefix}_esat.log
mv scripture2.log ${namePrefix}_scripture2.log
"""
}



//* autofill
//* platform
//* platform
//* autofill

process Single_Cell_Module_Tophat2_ESAT_Summary {

input:
 set val(name), file(esat_log) from g125_87_log_file20_g125_93.groupTuple()

output:
 val "esat_sum"  into g125_93_name01_g125_94
 file "*.tsv"  into g125_93_outFileTSV10_g125_94

errorStrategy 'retry'
maxRetries 3

shell:
'''
#!/usr/bin/env perl
use List::Util qw[min max];
use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage; 
use Data::Dumper;

my %tsv;
my @headers = ();
my $name = "!{name}";

alteredAligned();

my @keys = keys %tsv;
my $summary = "$name"."_esat_sum.tsv";
my $header_string = join("\\t", @headers);
`echo "$header_string" > $summary`;
foreach my $key (@keys){
	my $values = join("\\t", @{ $tsv{$key} });
	`echo "$values" >> $summary`;
}


sub alteredAligned
{
	my @files = qw(!{esat_log});
	my $dedupSum;
	my $alignedSum;
	my $inputCountSum;
	push(@headers, "Sample");
    push(@headers, "Total Reads");
	push(@headers, "Total aligned UMIs (ESAT)");
	push(@headers, "Total deduped UMIs (ESAT)");
	push(@headers, "Duplication Rate");
	# Total reads in: 718 Total reads out: 66
    # Total aligned UMIs: 56  Total de-duped UMIs: 56
	foreach my $file (@files){
		my $dedup;
		my $aligned;
		my $inputCount;
		chomp($inputCount = `cat $file | grep 'Total reads in:' |  head -n1| awk '{sum =\\$11} END {print sum}'`);
		chomp($aligned = `cat $file | grep 'Total aligned UMIs:' |  head -n1 | awk '{sum =\\$9} END {print sum}'`);
		chomp($dedup = `cat $file | grep 'Total de-duped UMIs:' |  head -n1 | awk '{sum =\\$13} END {print sum}'`);
		$dedupSum += int($dedup);
        $alignedSum += int($aligned);
        $inputCountSum += int($inputCount);
	}
	$tsv{$name} = [$name, $inputCountSum];
	my $duplicationRate = int($alignedSum)/int($dedupSum);
	$duplicationRate = sprintf("%.2f", $duplicationRate);
	push(@{$tsv{$name}}, $dedupSum);
	push(@{$tsv{$name}}, $alignedSum);
	push(@{$tsv{$name}}, $duplicationRate);
}
'''

}


process Single_Cell_Module_Tophat2_Merge_esat_summary {

input:
 file tsv from g125_93_outFileTSV10_g125_94.collect()
 val outputFileName from g125_93_name01_g125_94.collect()

output:
 file "${name}.tsv"  into g125_94_outputFileTSV08_g_122

errorStrategy 'retry'
maxRetries 3

script:
name = outputFileName[0]
"""    
awk 'FNR==1 && NR!=1 {  getline; } 1 {print} ' *.tsv > ${name}.tsv
"""
}

//* params.cleanLowEndUmis_path =  ""  //* @input

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 30
}
//* platform
//* platform
//* autofill

process Single_Cell_Module_Tophat2_UMI_Trim {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_umiClean.tsv$/) "UMI_count_final_after_tophat2/$filename"}
input:
 set val(name), file(umi_dist) from g125_87_UMI_distributions10_g125_88.groupTuple()

output:
 set val(name), file("*_umiClean.tsv")  into g125_88_UMI_clean00_g125_96

errorStrategy 'retry'
maxRetries 5

script:
"""	
cat ${umi_dist} > ${name}_merged_umi.distributions.txt
python ${params.cleanLowEndUmis_path} \
-i ${name}_merged_umi.distributions.txt \
-o ${name}_umiClean.tsv \
-n 2
"""
}

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 1000
    $CPU  = 1
    $MEMORY = 100
    $QUEUE = "gpu"
}
//*

process Single_Cell_Module_Tophat2_import_count_data {

input:
 set val(name), file(umi_dist) from g125_88_UMI_clean00_g125_96

output:
 file "${name}_counts.tsv"  into g125_96_outFileTSV00_g125_98
 val "gene_cell_counts"  into g125_96_name11_g125_98

shell:
'''
#!/usr/local/bin/Rscript
filelist = list.files(path = ".", pattern = "*", all.files = FALSE)
sink("import_count_data.log")
master_data <- data.frame()
summary_table <- matrix(ncol = 4, nrow = length(filelist))
rownames(summary_table) <- "!{name}"
colnames(summary_table) <- c("Number of Barcodes", "Mean UMIs per Barcode", "Number of Genes", "Mean Genes per Barcode")

cutoff <- 0
for(i in 1:length(filelist)){
  sample_input <- filelist[i]
  sample <- strsplit(sample_input, split = "\\\\.")[[1]]
  sample <- sample[1:(length(sample)-1)]
  print(paste0("Starting Sample ", i))
  print(sample)
  tmp <- read.table(sample_input, sep = "\\t", row.names = 1, header = T, quote = "")
  cSum <- apply(tmp,2,sum)
  valid_cells <- which(cSum >= cutoff)
  tmp <- tmp[,valid_cells]
  colnames(tmp) <- paste0(sample, colnames(tmp))
  print(paste0(ncol(tmp)," cells"))
  var_a <- ncol(tmp)
  cSum <- apply(tmp,2,sum)
  print(paste0("Mean UMIs per cell = ", mean(cSum)))
  var_b <-  mean(cSum)
  print(paste0("Median UMIs per cell = ", median(cSum)))
  var_c <- median(cSum)
  print(paste0(nrow(tmp)," genes"))
  print(paste0(ncol(tmp)," cells"))
  var_d <- nrow(tmp)
  tmp_genecount <- tmp
  tmp_genecount[tmp_genecount > 0] <- 1
  gSum <- apply(tmp_genecount,2,sum)
  print(paste0("Mean genes per cell = ", mean(gSum)))
  var_e <- mean(gSum)
  print(paste0("Median genes per cell = ", median(gSum)))
  var_f <- median(gSum)
  master_data <- merge(master_data, tmp, by = 0, all = T)
  rownames(master_data) <- master_data[,1]
  master_data <- master_data[,2:ncol(master_data)]
  print(paste0("Sample ", i, "Complete, Master Data Size is..."))
  print(dim(master_data))
  var_b = round(var_b, digits = 2)
  var_e = round(var_e, digits = 2)
  summary_table[i,] <-  c(var_a, var_b, var_d, var_e)

  if(i == length(filelist)){
    master_data <- as.data.frame(master_data)
    master_data[is.na(master_data)] <- 0
  }
}

summary_table <- cbind(sample = rownames(summary_table), summary_table)

write.table(summary_table, file='!{name}_counts.tsv', quote=FALSE, sep='\t', col.names = TRUE, row.names = FALSE)
'''
}


process Single_Cell_Module_Tophat2_Merge_count_sum {

input:
 file tsv from g125_96_outFileTSV00_g125_98.collect()
 val outputFileName from g125_96_name11_g125_98.collect()

output:
 file "${name}.tsv"  into g125_98_outputFileTSV01_g_122

errorStrategy 'retry'
maxRetries 3

script:
name = outputFileName[0]
"""    
awk 'FNR==1 && NR!=1 {  getline; } 1 {print} ' *.tsv > ${name}.tsv
"""
}

//* params.countUniqueAlignedBarcodes_fromFile_filePath =  ""  //* @input

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 500
    $CPU  = 1
    $MEMORY = 8
    $QUEUE = "long"
}
//*
if (!((params.run_Single_Cell_Module && (params.run_Single_Cell_Module == "yes")) || !params.run_Single_Cell_Module)){
g126_92_bam_file00_g126_90.set{g126_90_sorted_bam00_g126_91}
g126_92_bam_index11_g126_90.set{g126_90_bam_index12_g126_91}
g126_90_count_file21_g126_91 = Channel.empty()
} else {


process Single_Cell_Module_Hisat2_Count_cells {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_count.txt$/) "cell_counts_hisat2/$filename"}
input:
 set val(oldname), file(sorted_bams) from g126_92_bam_file00_g126_90
 set val(oldname), file(bams_index) from g126_92_bam_index11_g126_90
 val cutoff_reads_per_cell from g_118_cutoff2_g126_90

output:
 set val(oldname), file("bam/*.bam")  into g126_90_sorted_bam00_g126_91
 set val(oldname), file("bam/*.bam.bai")  into g126_90_bam_index12_g126_91
 set val(oldname), file("*_count.txt")  into g126_90_count_file21_g126_91

errorStrategy 'retry'

when:
(params.run_Single_Cell_Module && (params.run_Single_Cell_Module == "yes")) || !params.run_Single_Cell_Module

script:
"""
find  -name "*.bam" > filelist.txt
python ${params.countUniqueAlignedBarcodes_fromFile_filePath} -i filelist.txt -m ${cutoff_reads_per_cell} -o ${oldname}_count.txt
mkdir bam
mv $sorted_bams bam/.
mv $bams_index bam/.
"""
}
}


//* params.filter_lowCountBC_bam_print_py_filePath =  ""  //* @input
maxCellsForTmpFile = params.Single_Cell_Module_Hisat2_filter_lowCount.maxCellsForTmpFile

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 500
    $CPU  = 1
    $MEMORY = 8
    $QUEUE = "long"
}
//*

process Single_Cell_Module_Hisat2_filter_lowCount {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${name}_filtered_.*.bam$/) "filtered_bam_hisat2/$filename"}
input:
 set val(oldname), file(sorted_bams) from g126_90_sorted_bam00_g126_91
 set val(name), file(count_file) from g126_90_count_file21_g126_91
 set val(oldname), file(bam_index) from g126_90_bam_index12_g126_91
 val cutoff_for_filter from g_118_cutoff3_g126_91

output:
 set val(name), file("${name}_filtered_*.bam") optional true  into g126_91_filtered_bam00_g126_87

errorStrategy 'retry'
maxRetries 3

script:
"""
python ${params.filter_lowCountBC_bam_print_py_filePath} -i ${sorted_bams} -b ${name}_count.txt -o ${name}_filtered.bam -n ${cutoff_for_filter} -c ${maxCellsForTmpFile}
"""
}

esat_parameters = params.Single_Cell_Module_Hisat2_ESAT.esat_parameters
esat_RAM = params.Single_Cell_Module_Hisat2_ESAT.esat_RAM
//* params.ESAT_path =  ""  //* @input
//* params.gene_to_transcript_mapping_file =  ""  //* @input


//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 40
}
//* platform
//* platform
//* autofill

process Single_Cell_Module_Hisat2_ESAT {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.(txt|log)$/) "esat_after_hisat2/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*umi.distributions.txt$/) "esat_after_hisat2/$filename"}
input:
 set val(name), file(filtered_bam) from g126_91_filtered_bam00_g126_87.transpose()

output:
 file "*.{txt,log}"  into g126_87_outputFileTxt00
 set val(name), file("*umi.distributions.txt") optional true  into g126_87_UMI_distributions10_g126_88
 set val(name), file("${namePrefix}_esat.log")  into g126_87_log_file20_g126_93

errorStrategy 'retry'
maxRetries 1

script:
nameAll = filtered_bam.toString()
namePrefix = nameAll - ".bam"
"""    
find  -name "*.bam" | awk '{print "${namePrefix}\t"\$1 }' > ${namePrefix}_filelist.txt
java -Xmx${esat_RAM}g -jar ${params.ESAT_path} -alignments ${namePrefix}_filelist.txt -out ${namePrefix}_esat.txt -geneMapping ${params.gene_to_transcript_mapping_file} ${esat_parameters} > ${namePrefix}_esat.log
mv scripture2.log ${namePrefix}_scripture2.log
"""
}



//* autofill
//* platform
//* platform
//* autofill

process Single_Cell_Module_Hisat2_ESAT_Summary {

input:
 set val(name), file(esat_log) from g126_87_log_file20_g126_93.groupTuple()

output:
 val "esat_sum"  into g126_93_name01_g126_94
 file "*.tsv"  into g126_93_outFileTSV10_g126_94

errorStrategy 'retry'
maxRetries 3

shell:
'''
#!/usr/bin/env perl
use List::Util qw[min max];
use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage; 
use Data::Dumper;

my %tsv;
my @headers = ();
my $name = "!{name}";

alteredAligned();

my @keys = keys %tsv;
my $summary = "$name"."_esat_sum.tsv";
my $header_string = join("\\t", @headers);
`echo "$header_string" > $summary`;
foreach my $key (@keys){
	my $values = join("\\t", @{ $tsv{$key} });
	`echo "$values" >> $summary`;
}


sub alteredAligned
{
	my @files = qw(!{esat_log});
	my $dedupSum;
	my $alignedSum;
	my $inputCountSum;
	push(@headers, "Sample");
    push(@headers, "Total Reads");
	push(@headers, "Total aligned UMIs (ESAT)");
	push(@headers, "Total deduped UMIs (ESAT)");
	push(@headers, "Duplication Rate");
	# Total reads in: 718 Total reads out: 66
    # Total aligned UMIs: 56  Total de-duped UMIs: 56
	foreach my $file (@files){
		my $dedup;
		my $aligned;
		my $inputCount;
		chomp($inputCount = `cat $file | grep 'Total reads in:' |  head -n1| awk '{sum =\\$11} END {print sum}'`);
		chomp($aligned = `cat $file | grep 'Total aligned UMIs:' |  head -n1 | awk '{sum =\\$9} END {print sum}'`);
		chomp($dedup = `cat $file | grep 'Total de-duped UMIs:' |  head -n1 | awk '{sum =\\$13} END {print sum}'`);
		$dedupSum += int($dedup);
        $alignedSum += int($aligned);
        $inputCountSum += int($inputCount);
	}
	$tsv{$name} = [$name, $inputCountSum];
	my $duplicationRate = int($alignedSum)/int($dedupSum);
	$duplicationRate = sprintf("%.2f", $duplicationRate);
	push(@{$tsv{$name}}, $dedupSum);
	push(@{$tsv{$name}}, $alignedSum);
	push(@{$tsv{$name}}, $duplicationRate);
}
'''

}


process Single_Cell_Module_Hisat2_Merge_esat_summary {

input:
 file tsv from g126_93_outFileTSV10_g126_94.collect()
 val outputFileName from g126_93_name01_g126_94.collect()

output:
 file "${name}.tsv"  into g126_94_outputFileTSV07_g_122

errorStrategy 'retry'
maxRetries 3

script:
name = outputFileName[0]
"""    
awk 'FNR==1 && NR!=1 {  getline; } 1 {print} ' *.tsv > ${name}.tsv
"""
}

//* params.cleanLowEndUmis_path =  ""  //* @input

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 30
}
//* platform
//* platform
//* autofill

process Single_Cell_Module_Hisat2_UMI_Trim {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_umiClean.tsv$/) "UMI_count_final_after_hisat2/$filename"}
input:
 set val(name), file(umi_dist) from g126_87_UMI_distributions10_g126_88.groupTuple()

output:
 set val(name), file("*_umiClean.tsv")  into g126_88_UMI_clean00_g126_96

errorStrategy 'retry'
maxRetries 5

script:
"""	
cat ${umi_dist} > ${name}_merged_umi.distributions.txt
python ${params.cleanLowEndUmis_path} \
-i ${name}_merged_umi.distributions.txt \
-o ${name}_umiClean.tsv \
-n 2
"""
}

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 1000
    $CPU  = 1
    $MEMORY = 100
    $QUEUE = "gpu"
}
//*

process Single_Cell_Module_Hisat2_import_count_data {

input:
 set val(name), file(umi_dist) from g126_88_UMI_clean00_g126_96

output:
 file "${name}_counts.tsv"  into g126_96_outFileTSV00_g126_98
 val "gene_cell_counts"  into g126_96_name11_g126_98

shell:
'''
#!/usr/local/bin/Rscript
filelist = list.files(path = ".", pattern = "*", all.files = FALSE)
sink("import_count_data.log")
master_data <- data.frame()
summary_table <- matrix(ncol = 4, nrow = length(filelist))
rownames(summary_table) <- "!{name}"
colnames(summary_table) <- c("Number of Barcodes", "Mean UMIs per Barcode", "Number of Genes", "Mean Genes per Barcode")

cutoff <- 0
for(i in 1:length(filelist)){
  sample_input <- filelist[i]
  sample <- strsplit(sample_input, split = "\\\\.")[[1]]
  sample <- sample[1:(length(sample)-1)]
  print(paste0("Starting Sample ", i))
  print(sample)
  tmp <- read.table(sample_input, sep = "\\t", row.names = 1, header = T, quote = "")
  cSum <- apply(tmp,2,sum)
  valid_cells <- which(cSum >= cutoff)
  tmp <- tmp[,valid_cells]
  colnames(tmp) <- paste0(sample, colnames(tmp))
  print(paste0(ncol(tmp)," cells"))
  var_a <- ncol(tmp)
  cSum <- apply(tmp,2,sum)
  print(paste0("Mean UMIs per cell = ", mean(cSum)))
  var_b <-  mean(cSum)
  print(paste0("Median UMIs per cell = ", median(cSum)))
  var_c <- median(cSum)
  print(paste0(nrow(tmp)," genes"))
  print(paste0(ncol(tmp)," cells"))
  var_d <- nrow(tmp)
  tmp_genecount <- tmp
  tmp_genecount[tmp_genecount > 0] <- 1
  gSum <- apply(tmp_genecount,2,sum)
  print(paste0("Mean genes per cell = ", mean(gSum)))
  var_e <- mean(gSum)
  print(paste0("Median genes per cell = ", median(gSum)))
  var_f <- median(gSum)
  master_data <- merge(master_data, tmp, by = 0, all = T)
  rownames(master_data) <- master_data[,1]
  master_data <- master_data[,2:ncol(master_data)]
  print(paste0("Sample ", i, "Complete, Master Data Size is..."))
  print(dim(master_data))
  var_b = round(var_b, digits = 2)
  var_e = round(var_e, digits = 2)
  summary_table[i,] <-  c(var_a, var_b, var_d, var_e)

  if(i == length(filelist)){
    master_data <- as.data.frame(master_data)
    master_data[is.na(master_data)] <- 0
  }
}

summary_table <- cbind(sample = rownames(summary_table), summary_table)

write.table(summary_table, file='!{name}_counts.tsv', quote=FALSE, sep='\t', col.names = TRUE, row.names = FALSE)
'''
}


process Single_Cell_Module_Hisat2_Merge_count_sum {

input:
 file tsv from g126_96_outFileTSV00_g126_98.collect()
 val outputFileName from g126_96_name11_g126_98.collect()

output:
 file "${name}.tsv"  into g126_98_outputFileTSV05_g_122

errorStrategy 'retry'
maxRetries 3

script:
name = outputFileName[0]
"""    
awk 'FNR==1 && NR!=1 {  getline; } 1 {print} ' *.tsv > ${name}.tsv
"""
}

//* params.countUniqueAlignedBarcodes_fromFile_filePath =  ""  //* @input

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 500
    $CPU  = 1
    $MEMORY = 8
    $QUEUE = "long"
}
//*
if (!((params.run_Single_Cell_Module && (params.run_Single_Cell_Module == "yes")) || !params.run_Single_Cell_Module)){
g127_92_bam_file00_g127_90.set{g127_90_sorted_bam00_g127_91}
g127_92_bam_index11_g127_90.set{g127_90_bam_index12_g127_91}
g127_90_count_file21_g127_91 = Channel.empty()
} else {


process Single_Cell_Module_STAR_Count_cells {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_count.txt$/) "cell_counts_star/$filename"}
input:
 set val(oldname), file(sorted_bams) from g127_92_bam_file00_g127_90
 set val(oldname), file(bams_index) from g127_92_bam_index11_g127_90
 val cutoff_reads_per_cell from g_118_cutoff2_g127_90

output:
 set val(oldname), file("bam/*.bam")  into g127_90_sorted_bam00_g127_91
 set val(oldname), file("bam/*.bam.bai")  into g127_90_bam_index12_g127_91
 set val(oldname), file("*_count.txt")  into g127_90_count_file21_g127_91

errorStrategy 'retry'

when:
(params.run_Single_Cell_Module && (params.run_Single_Cell_Module == "yes")) || !params.run_Single_Cell_Module

script:
"""
find  -name "*.bam" > filelist.txt
python ${params.countUniqueAlignedBarcodes_fromFile_filePath} -i filelist.txt -m ${cutoff_reads_per_cell} -o ${oldname}_count.txt
mkdir bam
mv $sorted_bams bam/.
mv $bams_index bam/.
"""
}
}


//* params.filter_lowCountBC_bam_print_py_filePath =  ""  //* @input
maxCellsForTmpFile = params.Single_Cell_Module_STAR_filter_lowCount.maxCellsForTmpFile

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 500
    $CPU  = 1
    $MEMORY = 8
    $QUEUE = "long"
}
//*

process Single_Cell_Module_STAR_filter_lowCount {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${name}_filtered_.*.bam$/) "filtered_bam_star/$filename"}
input:
 set val(oldname), file(sorted_bams) from g127_90_sorted_bam00_g127_91
 set val(name), file(count_file) from g127_90_count_file21_g127_91
 set val(oldname), file(bam_index) from g127_90_bam_index12_g127_91
 val cutoff_for_filter from g_118_cutoff3_g127_91

output:
 set val(name), file("${name}_filtered_*.bam") optional true  into g127_91_filtered_bam00_g127_87

errorStrategy 'retry'
maxRetries 3

script:
"""
python ${params.filter_lowCountBC_bam_print_py_filePath} -i ${sorted_bams} -b ${name}_count.txt -o ${name}_filtered.bam -n ${cutoff_for_filter} -c ${maxCellsForTmpFile}
"""
}

esat_parameters = params.Single_Cell_Module_STAR_ESAT.esat_parameters
esat_RAM = params.Single_Cell_Module_STAR_ESAT.esat_RAM
//* params.ESAT_path =  ""  //* @input
//* params.gene_to_transcript_mapping_file =  ""  //* @input


//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 40
}
//* platform
//* platform
//* autofill

process Single_Cell_Module_STAR_ESAT {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.(txt|log)$/) "esat_after_star/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*umi.distributions.txt$/) "esat_after_star/$filename"}
input:
 set val(name), file(filtered_bam) from g127_91_filtered_bam00_g127_87.transpose()

output:
 file "*.{txt,log}"  into g127_87_outputFileTxt00
 set val(name), file("*umi.distributions.txt") optional true  into g127_87_UMI_distributions10_g127_88
 set val(name), file("${namePrefix}_esat.log")  into g127_87_log_file20_g127_93

errorStrategy 'retry'
maxRetries 1

script:
nameAll = filtered_bam.toString()
namePrefix = nameAll - ".bam"
"""    
find  -name "*.bam" | awk '{print "${namePrefix}\t"\$1 }' > ${namePrefix}_filelist.txt
java -Xmx${esat_RAM}g -jar ${params.ESAT_path} -alignments ${namePrefix}_filelist.txt -out ${namePrefix}_esat.txt -geneMapping ${params.gene_to_transcript_mapping_file} ${esat_parameters} > ${namePrefix}_esat.log
mv scripture2.log ${namePrefix}_scripture2.log
"""
}



//* autofill
//* platform
//* platform
//* autofill

process Single_Cell_Module_STAR_ESAT_Summary {

input:
 set val(name), file(esat_log) from g127_87_log_file20_g127_93.groupTuple()

output:
 val "esat_sum"  into g127_93_name01_g127_94
 file "*.tsv"  into g127_93_outFileTSV10_g127_94

errorStrategy 'retry'
maxRetries 3

shell:
'''
#!/usr/bin/env perl
use List::Util qw[min max];
use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage; 
use Data::Dumper;

my %tsv;
my @headers = ();
my $name = "!{name}";

alteredAligned();

my @keys = keys %tsv;
my $summary = "$name"."_esat_sum.tsv";
my $header_string = join("\\t", @headers);
`echo "$header_string" > $summary`;
foreach my $key (@keys){
	my $values = join("\\t", @{ $tsv{$key} });
	`echo "$values" >> $summary`;
}


sub alteredAligned
{
	my @files = qw(!{esat_log});
	my $dedupSum;
	my $alignedSum;
	my $inputCountSum;
	push(@headers, "Sample");
    push(@headers, "Total Reads");
	push(@headers, "Total aligned UMIs (ESAT)");
	push(@headers, "Total deduped UMIs (ESAT)");
	push(@headers, "Duplication Rate");
	# Total reads in: 718 Total reads out: 66
    # Total aligned UMIs: 56  Total de-duped UMIs: 56
	foreach my $file (@files){
		my $dedup;
		my $aligned;
		my $inputCount;
		chomp($inputCount = `cat $file | grep 'Total reads in:' |  head -n1| awk '{sum =\\$11} END {print sum}'`);
		chomp($aligned = `cat $file | grep 'Total aligned UMIs:' |  head -n1 | awk '{sum =\\$9} END {print sum}'`);
		chomp($dedup = `cat $file | grep 'Total de-duped UMIs:' |  head -n1 | awk '{sum =\\$13} END {print sum}'`);
		$dedupSum += int($dedup);
        $alignedSum += int($aligned);
        $inputCountSum += int($inputCount);
	}
	$tsv{$name} = [$name, $inputCountSum];
	my $duplicationRate = int($alignedSum)/int($dedupSum);
	$duplicationRate = sprintf("%.2f", $duplicationRate);
	push(@{$tsv{$name}}, $dedupSum);
	push(@{$tsv{$name}}, $alignedSum);
	push(@{$tsv{$name}}, $duplicationRate);
}
'''

}


process Single_Cell_Module_STAR_Merge_esat_summary {

input:
 file tsv from g127_93_outFileTSV10_g127_94.collect()
 val outputFileName from g127_93_name01_g127_94.collect()

output:
 file "${name}.tsv"  into g127_94_outputFileTSV09_g_122

errorStrategy 'retry'
maxRetries 3

script:
name = outputFileName[0]
"""    
awk 'FNR==1 && NR!=1 {  getline; } 1 {print} ' *.tsv > ${name}.tsv
"""
}

//* params.cleanLowEndUmis_path =  ""  //* @input

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 30
}
//* platform
//* platform
//* autofill

process Single_Cell_Module_STAR_UMI_Trim {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*_umiClean.tsv$/) "UMI_count_final_after_star/$filename"}
input:
 set val(name), file(umi_dist) from g127_87_UMI_distributions10_g127_88.groupTuple()

output:
 set val(name), file("*_umiClean.tsv")  into g127_88_UMI_clean00_g127_96

errorStrategy 'retry'
maxRetries 5

script:
"""	
cat ${umi_dist} > ${name}_merged_umi.distributions.txt
python ${params.cleanLowEndUmis_path} \
-i ${name}_merged_umi.distributions.txt \
-o ${name}_umiClean.tsv \
-n 2
"""
}

//* autofill
if ($HOSTNAME == "ghpcc06.umassrc.org"){
    $TIME = 1000
    $CPU  = 1
    $MEMORY = 100
    $QUEUE = "gpu"
}
//*

process Single_Cell_Module_STAR_import_count_data {

input:
 set val(name), file(umi_dist) from g127_88_UMI_clean00_g127_96

output:
 file "${name}_counts.tsv"  into g127_96_outFileTSV00_g127_98
 val "gene_cell_counts"  into g127_96_name11_g127_98

shell:
'''
#!/usr/local/bin/Rscript
filelist = list.files(path = ".", pattern = "*", all.files = FALSE)
sink("import_count_data.log")
master_data <- data.frame()
summary_table <- matrix(ncol = 4, nrow = length(filelist))
rownames(summary_table) <- "!{name}"
colnames(summary_table) <- c("Number of Barcodes", "Mean UMIs per Barcode", "Number of Genes", "Mean Genes per Barcode")

cutoff <- 0
for(i in 1:length(filelist)){
  sample_input <- filelist[i]
  sample <- strsplit(sample_input, split = "\\\\.")[[1]]
  sample <- sample[1:(length(sample)-1)]
  print(paste0("Starting Sample ", i))
  print(sample)
  tmp <- read.table(sample_input, sep = "\\t", row.names = 1, header = T, quote = "")
  cSum <- apply(tmp,2,sum)
  valid_cells <- which(cSum >= cutoff)
  tmp <- tmp[,valid_cells]
  colnames(tmp) <- paste0(sample, colnames(tmp))
  print(paste0(ncol(tmp)," cells"))
  var_a <- ncol(tmp)
  cSum <- apply(tmp,2,sum)
  print(paste0("Mean UMIs per cell = ", mean(cSum)))
  var_b <-  mean(cSum)
  print(paste0("Median UMIs per cell = ", median(cSum)))
  var_c <- median(cSum)
  print(paste0(nrow(tmp)," genes"))
  print(paste0(ncol(tmp)," cells"))
  var_d <- nrow(tmp)
  tmp_genecount <- tmp
  tmp_genecount[tmp_genecount > 0] <- 1
  gSum <- apply(tmp_genecount,2,sum)
  print(paste0("Mean genes per cell = ", mean(gSum)))
  var_e <- mean(gSum)
  print(paste0("Median genes per cell = ", median(gSum)))
  var_f <- median(gSum)
  master_data <- merge(master_data, tmp, by = 0, all = T)
  rownames(master_data) <- master_data[,1]
  master_data <- master_data[,2:ncol(master_data)]
  print(paste0("Sample ", i, "Complete, Master Data Size is..."))
  print(dim(master_data))
  var_b = round(var_b, digits = 2)
  var_e = round(var_e, digits = 2)
  summary_table[i,] <-  c(var_a, var_b, var_d, var_e)

  if(i == length(filelist)){
    master_data <- as.data.frame(master_data)
    master_data[is.na(master_data)] <- 0
  }
}

summary_table <- cbind(sample = rownames(summary_table), summary_table)

write.table(summary_table, file='!{name}_counts.tsv', quote=FALSE, sep='\t', col.names = TRUE, row.names = FALSE)
'''
}


process Single_Cell_Module_STAR_Merge_count_sum {

input:
 file tsv from g127_96_outFileTSV00_g127_98.collect()
 val outputFileName from g127_96_name11_g127_98.collect()

output:
 file "${name}.tsv"  into g127_98_outputFileTSV06_g_122

errorStrategy 'retry'
maxRetries 3

script:
name = outputFileName[0]
"""    
awk 'FNR==1 && NR!=1 {  getline; } 1 {print} ' *.tsv > ${name}.tsv
"""
}

g103_11_outputFileTSV00_g_122= g103_11_outputFileTSV00_g_122.ifEmpty([""]) 
g125_98_outputFileTSV01_g_122= g125_98_outputFileTSV01_g_122.ifEmpty([""]) 
g87_2_outputFile02_g_122= g87_2_outputFile02_g_122.ifEmpty([""]) 
g_128_outputFileTSV03_g_122= g_128_outputFileTSV03_g_122.ifEmpty([""]) 
g80_3_report04_g_122= g80_3_report04_g_122.ifEmpty([""]) 
g126_98_outputFileTSV05_g_122= g126_98_outputFileTSV05_g_122.ifEmpty([""]) 
g127_98_outputFileTSV06_g_122= g127_98_outputFileTSV06_g_122.ifEmpty([""]) 
g126_94_outputFileTSV07_g_122= g126_94_outputFileTSV07_g_122.ifEmpty([""]) 
g125_94_outputFileTSV08_g_122= g125_94_outputFileTSV08_g_122.ifEmpty([""]) 
g127_94_outputFileTSV09_g_122= g127_94_outputFileTSV09_g_122.ifEmpty([""]) 

//* autofill
//* platform
//* platform
//* autofill

process Overall_Summary {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /overall_summary.tsv$/) "summary/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /overall_summary.tsv$/) "multiqc/$filename"}
input:
 file starSum from g103_11_outputFileTSV00_g_122
 file sequentialSum from g125_98_outputFileTSV01_g_122
 file hisatSum from g87_2_outputFile02_g_122
 file rsemSum from g_128_outputFileTSV03_g_122
 file tophatSum from g80_3_report04_g_122
 file adapterSum from g126_98_outputFileTSV05_g_122
 file trimmerSum from g127_98_outputFileTSV06_g_122
 file qualitySum from g126_94_outputFileTSV07_g_122
 file umiSum from g125_94_outputFileTSV08_g_122
 file kallistoSum from g127_94_outputFileTSV09_g_122

output:
 file "overall_summary.tsv" optional true  into g_122_outputFileTSV00

shell:
'''
#!/usr/bin/env perl
use List::Util qw[min max];
use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

my @header;
my %all_rows;
my @seen_cols;
my $ID_header;

chomp(my $contents = `ls *.tsv`);
my @rawFiles = split(/[\\n]+/, $contents);
if (scalar @rawFiles == 0){
    exit;
}
my @files = ();
# order must be in this order for chipseq pipeline: bowtie->dedup
# rsem bam pipeline: dedup->rsem, star->dedup
# riboseq ncRNA_removal->star
my @order = ("adapter_removal","trimmer","quality","extractUMI","extractValid","tRAX","sequential_mapping","ncRNA_removal","bowtie","star","hisat2","tophat2", "dedup","rsem","kallisto","esat","count");
for ( my $k = 0 ; $k <= $#order ; $k++ ) {
    for ( my $i = 0 ; $i <= $#rawFiles ; $i++ ) {
        if ( $rawFiles[$i] =~ /$order[$k]/ ) {
            push @files, $rawFiles[$i];
        }
    }
}

print Dumper \\@files;
##add rest of the files
for ( my $i = 0 ; $i <= $#rawFiles ; $i++ ) {
    push(@files, $rawFiles[$i]) unless grep{$_ == $rawFiles[$i]} @files;
}
print Dumper \\@files;

##Merge each file according to array order

foreach my $file (@files){
        open IN,"$file";
        my $line1 = <IN>;
        chomp($line1);
        ( $ID_header, my @header) = ( split("\\t", $line1) );
        push @seen_cols, @header;

        while (my $line=<IN>) {
        chomp($line);
        my ( $ID, @fields ) = ( split("\\t", $line) ); 
        my %this_row;
        @this_row{@header} = @fields;

        #print Dumper \\%this_row;

        foreach my $column (@header) {
            if (! exists $all_rows{$ID}{$column}) {
                $all_rows{$ID}{$column} = $this_row{$column}; 
            }
        }   
    }
    close IN;
}

#print for debugging
#print Dumper \\%all_rows;
#print Dumper \\%seen_cols;

#grab list of column headings we've seen, and order them. 
my @cols_to_print = uniq(@seen_cols);
my $summary = "overall_summary.tsv";
open OUT, ">$summary";
print OUT join ("\\t", $ID_header,@cols_to_print),"\\n";
foreach my $key ( keys %all_rows ) { 
    #map iterates all the columns, and gives the value or an empty string. if it's undefined. (prevents errors)
    print OUT join ("\\t", $key, (map { $all_rows{$key}{$_} // '' } @cols_to_print)),"\\n";
}
close OUT;

sub uniq {
    my %seen;
    grep ! $seen{$_}++, @_;
}

'''


}


workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
