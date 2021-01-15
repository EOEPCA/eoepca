baseCommand: Stars
class: CommandLineTool
hints:
  DockerRequirement:
    dockerPull: terradue/stars-t2:latest
id: stars
arguments:
- copy
- -rel
- -r
- '4'
- -o
- ./
inputs: {}
outputs: {}
requirements:
  EnvVarRequirement:
    envDef:
      PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  ResourceRequirement: {}