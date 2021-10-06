$graph:
- baseCommand: nhi
  class: CommandLineTool
  hints:
    DockerRequirement:
      dockerPull: registry.hub.docker.com/eoepcaci/nhi:dev0.0.3
  id: clt
  inputs:
    input_reference:
      inputBinding:
        position: 1
        prefix: --input_reference
      type: Directory
    threshold:
      inputBinding:
        position: 2
        prefix: --threshold
      type: string
    aoi:
      inputBinding:
        position: 3
        prefix: --aoi
      type: string?
  outputs:
    results:
      outputBinding:
        glob: .
      type: Directory
  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/srv/conda/envs/env_app_snuggs/bin
    ResourceRequirement: {}
  stderr: std.err
  stdout: std.out
- class: Workflow
  doc: Normalized Hotspot Indices
  id: nhi
  inputs:
    input_reference:
      doc: Input product reference
      label: Input product reference
      type: Directory[]
    threshold:
      doc: Threshold for hotspot detection
      label: Threshold for hotspot detection
      type: string
    aoi:
      doc: Area of interest in Well-known Text (WKT)
      label: Area of interest in Well-known Text (WKT)
      type: string?
  label: nhi
  outputs:
  - id: wf_outputs
    outputSource:
    - step_1/results
    type:
      items: Directory
      type: array
  requirements:
  - class: ScatterFeatureRequirement
  steps:
    step_1:
      in:
        input_reference: input_reference
        threshold: threshold
        aoi: aoi
      out:
      - results
      run: '#clt'
      scatter: input_reference
      scatterMethod: dotproduct
$namespaces:
  s: https://schema.org/
cwlVersion: v1.0
s:softwareVersion: 0.0.3
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf

