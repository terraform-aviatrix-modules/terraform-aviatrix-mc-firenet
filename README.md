# terraform-aviatrix-mc-firenet

### Description
Aviatrix Terraform module for firenet deployment in multiple clouds, to be used in conjunction with [mc-transit module](https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit).
Initial support for AWS and Azure. Soon to be expanded to GCP and OCI.

### Diagram
\<Provide a diagram of the high level constructs thet will be created by this module>
<img src="<IMG URL>"  height="250">

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version | [mc-transit module](https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit) version
:--- | :--- | :--- | :--- | :---
v1.0.0 | >=1.0 | >=6.6 | >=2.21.1 | >=v2.0.0

### Usage Example
```
module "mc_transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "v2.0.0"

  cloud                  = "AWS"
  cidr                   = "10.1.0.0/23"
  region                 = "eu-central-1"
  account                = "AWS"
  enable_transit_firenet = true
}

module "firenet_1" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "1.0.0"

  tranit_module = module.mc_transit
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
}
```

### Variables
The following variables are required:

key | value
:--- | :---
transit_module | Refer to the mc-transit module that built the transit. This module plugs directly into it's output to build firenet on top of it.
firewall_image | The firewall image to be used to deploy the NGFW's.

The following variables are optional:

Key | Supported_CSP's |  Default value | Description
:-- | --: | :-- | :--
firewall_image_version | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/gcp.png?raw=true" title="GCP"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/oci.png?raw=true" title="OCI"> | | When not provided, latest available will be used.

### Outputs
This module will return the following outputs:

key | description
:---|:---
\<keyname> | \<description of object that will be returned in this output>

### Common Errors

When using a firewall_image string that does not exist, a data lookup will fail and throw the error below. Make sure you are using a valid firewall_image. These can differ between clouds. Check the Aviatrix UI to see available firewall images.
```
│ Error: Invalid index
│ 
│   on variables.tf line 172:
│   (source code not available)
│ 
│ The given key does not identify an element in this collection value: the collection has no elements.
```