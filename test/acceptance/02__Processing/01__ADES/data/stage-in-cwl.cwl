cwlVersion: v1.0
baseCommand: Stars
doc: "Run Stars for staging input data"
class: CommandLineTool
hints:
  DockerRequirement:
    dockerPull: terradue/stars-t2:0.6.18.19
id: stars
arguments:
  - copy
  - -v
  - -rel
  - -r
  - "4"
  - -o
  - ./
  - --harvest
inputs:
  ADES_STAGEIN_AWS_SERVICEURL:
    type: string?
  ADES_STAGEIN_AWS_ACCESS_KEY_ID:
    type: string?
  ADES_STAGEIN_AWS_SECRET_ACCESS_KEY:
    type: string?
outputs: {}
requirements:
  EnvVarRequirement:
    envDef:
      PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      # AWS__Profile: $(inputs.aws_profile)
      # AWS__ProfilesLocation: $(inputs.aws_profiles_location.path)
      AWS__ServiceURL: $(inputs.ADES_STAGEIN_AWS_SERVICEURL)
      AWS_ACCESS_KEY_ID: $(inputs.ADES_STAGEIN_AWS_ACCESS_KEY_ID)
      AWS_SECRET_ACCESS_KEY: $(inputs.ADES_STAGEIN_AWS_SECRET_ACCESS_KEY)
  ResourceRequirement: {}
