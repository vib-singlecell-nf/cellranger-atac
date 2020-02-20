nextflow.preview.dsl=2

toolParams = params.sc.cellranger_atac

def runCellRangerAtacCount = {
    id,
    sample,
    fastqs,
    processParams,
    expectCells = null ->
    return (
        """
        # --id: CellRanger will create a directory with this name in cellranger_parent_output_dir.
        # --sample: Start of FASTQ filenames that identifies a sample uniquely (multiple prefixes separated by ",").
        cellranger-atac count \
            --id=${id} \
            --sample=${id} \
            --fastqs=${fastqs.join(",")} \
            --reference=${processParams.reference} \
            ${(processParams.containsKey('forceCells')) ? '--force-cells ' + processParams.forceCells: ''} \
            ${(processParams.containsKey('dimReduce')) ? '--dim-reduce ' + processParams.dimReduce: ''} \
            ${(processParams.containsKey('downsample')) ? '--downsample ' + processParams.downsample: ''} \
            ${(processParams.containsKey('lanes')) ? '--lanes ' + processParams.lanes: ''} \
            ${(processParams.containsKey('localCores')) ? '--localcores ' + processParams.localCores: ''} \
            ${(processParams.containsKey('localMem')) ? '--localmem ' + processParams.localMem: ''} \
        """
    )
}

process SC__CELLRANGER_ATAC__COUNT {

    label toolParams.labels.processExecutor
    cache 'deep'
    container toolParams.container
    publishDir "${params.global.outdir}/counts", mode: 'link', overwrite: true
    clusterOptions "-l nodes=1:ppn=${toolParams.count.ppn} -l pmem=${toolParams.count.pmem} -l walltime=${toolParams.count.walltime} -A ${params.global.qsubaccount} -m abe -M ${params.global.qsubemail}"
    maxForks = toolParams.count.maxForks

    input:
        file(reference)
        tuple val(sampleId), file(fastqs)

    output:
        tuple val(sampleId), file("${sampleId}/outs")

    script:
        def sampleParams = params.parseConfig(sampleId, params.global, toolParams.count)
        processParams = sampleParams.local
        if(processParams.sample == '') {
            throw new Exception("Regards params.sc.cellranger_atac.count: sample parameter cannot be empty")
        }
        runCellRangerAtacCount(
            sampleId,
            sampleId,
            fastqs,
            processParams
        )

}

process SC__CELLRANGER_ATAC__COUNT_WITH_METADATA {

    label toolParams.labels.processExecutor
    cache 'deep'
    container toolParams.container
    publishDir "${params.global.outdir}/counts", mode: 'link', overwrite: true
    clusterOptions "-l nodes=1:ppn=${toolParams.count.ppn} -l pmem=${toolParams.count.pmem} -l walltime=${toolParams.count.walltime} -A ${params.global.qsubaccount} -m abe -M ${params.global.qsubemail}"
    maxForks = toolParams.count.maxForks

    input:
        tuple \
            val(sampleId), \
            val(samplePrefix), \
            file(fastqs), \
            val(expectCells)

    output:
        tuple \
            val(sampleId), \
            file("${sampleId}/outs")

    script:
        def sampleParams = params.parseConfig(sampleId, params.global, toolParams.count)
        processParams = sampleParams.local
        runCellRangerAtacCount(
            sampleId,
            samplePrefix,
            fastqs,
            processParams,
            expectCells
        )

}

