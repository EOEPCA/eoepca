class: Workflow
doc: Main stage manager
id: stage-manager
label: theStage
inputs:
  workflow:
    doc: workflow
    label: workflow
    type: string
  process:
    doc: process
    label: process
    type: string
outputs: {}
requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
steps:
  node_metrics_in:
    in:
      inp1: workflow
      inp2: process
    out:
      - results
    run:
      baseCommand: metrics
      hints:
        DockerRequirement:
          dockerPull: terradue/metrics:0.1
      class: CommandLineTool
      id: clt
      arguments:
        - prefix: --event
          position: 3
          valueFrom: "started"
      inputs:
        inp1:
          inputBinding:
            position: 1
            prefix: --workflow
          type: string
        inp2:
          inputBinding:
            position: 2
            prefix: --process
          type: string
      outputs:
        results:
          type: stdout
      requirements:
        EnvVarRequirement:
          envDef:
            PATH: /srv/conda/envs/env_metrics/bin:/opt/anaconda/bin:/usr/share/java/maven/bin:/opt/anaconda/bin:/opt/anaconda/envs/notebook/bin:/opt/anaconda/bin:/usr/share/java/maven/bin:/opt/anaconda/bin:/opt/anaconda/condabin:/opt/anaconda/bin:/usr/lib64/qt-3.3/bin:/usr/share/java/maven/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
        ResourceRequirement: { }
  node_stage_in:
    in:
      metrics: node_metrics_in/results
    out: []
    run: ''
#
#  on_stage:
#    in: {}
#    out: []
#    run: ''
#  node_stage_out:
#    in: {}
#    out: []
#    run: ''
  node_metrics_out:
    in:
      inp1: workflow
      inp2: process
    out:
      - results
    run:
      baseCommand: metrics
      hints:
        DockerRequirement:
          dockerPull: terradue/metrics:0.1
      class: CommandLineTool
      id: clt
      arguments:
        - prefix: --event
          position: 3
          valueFrom: "succeeded"
      inputs:
        inp1:
          inputBinding:
            position: 1
            prefix: --workflow
          type: string
        inp2:
          inputBinding:
            position: 1
            prefix: --process
          type: string
      outputs: {}
      requirements:
        EnvVarRequirement:
          envDef:
            PATH: /srv/conda/envs/env_metrics/bin:/opt/anaconda/bin:/usr/share/java/maven/bin:/opt/anaconda/bin:/opt/anaconda/envs/notebook/bin:/opt/anaconda/bin:/usr/share/java/maven/bin:/opt/anaconda/bin:/opt/anaconda/condabin:/opt/anaconda/bin:/usr/lib64/qt-3.3/bin:/usr/share/java/maven/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
        ResourceRequirement: { }