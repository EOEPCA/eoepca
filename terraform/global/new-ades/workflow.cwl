cwlVersion: v1.0

$namespaces:
  ows: http://www.opengis.net/ows/1.1
  stac: http://www.me.net/stac/cwl/extension
  schema: https://json-schema.org/draft/2019-09/schema

$graph:
- baseCommand: eoepca-metadata-extractor
  class: CommandLineTool
  hints:
    DockerRequirement:
      dockerPull: blasco/eoepca-eo-tools:latest
  id: metadata_extractor
  inputs:
    arg1:
    #   inputBinding:
    #     position: 1
    #     prefix: --base_dir
    #     valueFrom: $(self.path)
      type: Directory
      default: 
        class: Directory
        location: "/workspace"
    arg2:
      type: File
      inputBinding:
        position: 1
    arg3:
      type:
        type: array
        items: string
        # minLength: 2
        inputBinding:
          prefix: -B=
          separate: false
  outputs:
    results:
      outputBinding:
        glob: .
      type: Any
  requirements:
    EnvVarRequirement:
      envDef:
        PATH: /opt/anaconda/bin:/opt/anaconda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    ResourceRequirement: {}
    
  stderr: std.err
  stdout: std.out
- class: Workflow
  id: eo_metadata_generation # service id [WPS] map to wps:Input/ows:identifier
  label: Earth Observation Metadata Generation # title [WPS] map to wps:Input/ows:title
  doc: Earth Observation Metadata Generation # description [WPS] map to wps:Input/ows:abstract
  ows:version: 1.0 # workflow version
  inputs:
    optional_combo_parameter: # parameter id [WPS] map to wps:Input/ows:identifier
      doc: type blah blah blah # [WPS] maps to wps:Input/ows:abstract
      label: optional type options # [WPS] maps to wps:Input/ows:title
      type: 
        - "null" # null option --> optional (like '?') [WPS] maps to minOccurs = 0 (maxOccurs = 99 because it is an array)
        - type: enum # [WPS] maps to AllowedValues
          symbols: ['type1', 'type2', 'type3']
      
    array_string:
      type:
        type: enum
        schema:minItems: 2
        schema:maxItems: 10

    base_dir: 
      type: Directory? 
      ows:ignore: True # [WPS] no mapping

    input_file:
      doc: Mandatory input file to generate metadata for # [WPS] maps to wps:Input/ows:abstract
      label: EO input file # [WPS] maps to wps:Input/ows:title
      type: File # no question mark indicates it is not optional. [WPS] maps to minOccurs = 1 (maxOccurs = 1 because it is not an array)
      # This file can be referenced by a STAC catalog
      stac:catalog: # [WPS] maps to wps:Supported/wps:Format with mimetype = application/json & application/yaml
        stac:href: catalog.json # optional catalogue URL. Default to file 'catalog.json'.
        stac:collection_id: post_event # name of the collection to fetch the input from
      # This file can be also referenced as an OpenSearch URL
      opensearch:url: {} # [WPS] maps to wps:Supported/wps:Format with mimetype = application/atom+xml & application/opensearchdescription+xml

  outputs:
    results: # parameter id [WPS] map to wps:Output/ows:identifier
      label: Outputs blah blah
      outputSource:
      - step1/results
      type:
        items: Directory
        type: array

  steps:
    step1:
      in:
        arg1: base_dir
        arg2: input_file
        arg3: array_string
      out:
      - results
      run: '#metadata_extractor'

  requirements:
    SchemaDefRequirement:
      types:
        - $import: boundingBoxData.yaml

