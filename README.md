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

  transit_module = module.mc_transit
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
attached |<img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | true | Attach firewall instances to Aviatrix Gateways.
bootstrap_bucket_name_1 | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> | | Name of bootstrap bucket to pull firewall config from. (If bootstrap_bucket_name_2 is not set, this will used for all NGFW instances)
bootstrap_bucket_name_2 | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> | | Name of bootstrap bucket to pull firewall config from. (Only used if 2 or more FW instances are deployed, e.g. when ha_gw is true. Applies to "even" fw instances (2,4,6 etc))
custom_fw_names | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | [] | If set, the NGFW instances will be deployed with the names provided in this list. First half of the list for instances in az1, second half for az2.
east_west_inspection_excluded_cidrs | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | | Network List Excluded From East-West Inspection.
egress_enabled | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | false | Enable/disable internet egress via NGFW.
egress_static_cidrs | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | [] | List of egress static CIDRs. Egress is required to be enabled. Example: ["1.171.15.184/32", "1.171.15.185/32"].
fail_close_enabled | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | false | Set to true to enable fail close
firewall_image_id | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | | Firewall image ID. Applicable to AWS and Azure only. For AWS, please use AMI ID. For Azure, the format is “Publisher:Offer:Plan:Version”.
firewall_image_version | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | | When not provided, latest available will be used.
fw_amount | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | | The amount of NGFW instances to deploy. These will be deployed accross multiple AZ's. Amount must be even and only applies to when ha_gw enabled.
iam_role_1 | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> | | IAM Role used to access bootstrap bucket. (If iam_role_2 is not set, this will used for all NGFW instances)
iam_role_2 | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> | | IAM Role used to access bootstrap bucket. (Only used if 2 or more FW instances are deployed, e.g. when ha_gw is true. Applies to "even" fw instances (2,4,6 etc))
inspection_enabled | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | true | Enable/disable east/west + north/south inspection via NGFW.
instance_size | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <br> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | x<br>y | Size of the NGFW instances
keep_alive_via_lan_interface_enabled | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | False | Enable Keep Alive via Firewall LAN Interface.
tags | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | | Map of tags to assign to the firewall or FQDN egress gw's.
use_gwlb | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> | | Deploy firenet using the AWS GWLB.
user_data_1 | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | | Userdata to bootstrap FortiGate or Checkpoint Firewall.
user_data_2 | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/aws.png?raw=true" title="AWS"> <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | | Userdata to bootstrap FortiGate or Checkpoint Firewall. If not set, user_data_1 will be used.
username | <img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit/blob/main/img/azure.png?raw=true" title="Azure"> | fwadmin | Applicable to Azure or AzureGov deployment only. "admin" as a username is not accepted. (For Checkpoint it is always admin)

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
