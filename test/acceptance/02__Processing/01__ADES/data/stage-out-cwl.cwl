cwlVersion: v1.0
baseCommand: Stars
doc: "Run Stars for staging results"
class: CommandLineTool
hints:
  DockerRequirement:
    dockerPull: terradue/stars-t2:0.6.18.19
id: stars
arguments:
  - copy
  - -v
  - -r
  - "4"
inputs:
  ADES_STAGEOUT_AWS_PROFILE:
    type: string?
  ADES_STAGEOUT_AWS_SERVICEURL:
    type: string?
  ADES_STAGEOUT_AWS_ACCESS_KEY_ID:
    type: string?
  ADES_STAGEOUT_AWS_SECRET_ACCESS_KEY:
    type: string?
  aws_profiles_location:
    type: File?
  result_directory:
    type: Directory?
    inputBinding:
      position: 7
  ADES_STAGEOUT_OUTPUT:
    type: string?
    inputBinding:
      position: 5
      prefix: -o
      valueFrom: $( self + "/" + inputs.process )
  ADES_STAGEOUT_AWS_REGION:
    type: string?
  process:
    type: string?
    inputBinding:
      position: 6
      prefix: -res
      valueFrom: $( inputs.process + ".res" )
outputs: {}
requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      AWS__ServiceURL: $(inputs.ADES_STAGEOUT_AWS_SERVICEURL)
      AWS_ACCESS_KEY_ID: $(inputs.ADES_STAGEOUT_AWS_ACCESS_KEY_ID)
      AWS_SECRET_ACCESS_KEY: $(inputs.ADES_STAGEOUT_AWS_SECRET_ACCESS_KEY)
      AWS__SignatureVersion: "2"
  ResourceRequirement: {}
