# terraform-aviatrix-mc-firenet

### Description
Aviatrix Terraform module for firenet deployment in multiple clouds, to be used in conjunction with mc-transit module.

### Diagram
\<Provide a diagram of the high level constructs thet will be created by this module>
<img src="<IMG URL>"  height="250">

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v1.0.0 | >=1.0 | >=6.5 | >=2.20.3

### Usage Example
```
module "firenet_1" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "1.0.0"

  tranit_module = module.tranit_1
}
```

### Variables
The following variables are required:

key | value
:--- | :---
transit_module | Refer to the mc-transit module that built the transit. This module plugs directly into it's output to build firenet on top of it.

The following variables are optional:

key | default | value 
:---|:---|:---
\<keyname> | \<default value> | \<description of value that should be provided in this variable>

### Outputs
This module will return the following outputs:

key | description
:---|:---
\<keyname> | \<description of object that will be returned in this output>
