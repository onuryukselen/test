$HOSTNAME = ""
params.outdir = 'results'  


if (!params.inputparam){params.inputparam = ""} 

g_1_csvFile0_g_0 = file(params.inputparam, type: 'any')


process test {

input:
 file test from g_1_csvFile0_g_0

output:
 file "test2.csv"  into g_0_csvFile00_g_2

"""
mv $test test2.csv
"""
}


process splitCsv {

input:
 val test2 from g_0_csvFile00_g_2.splitCsv().map{row->row[0]}


script:
println test2
"""
echo ""
"""
}


workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
