# terraform-aviatrix-mc-firenet release notes

## 8.0.0
### Version Alignment
Starting with this release, this Terraform module will align its version with the Aviatrix Controller version. This means the module version has jumped from v1.6.0 to v8.0.0 to align with the Controller’s latest major version. This change makes it easier to determine which module version is compatible with which Controller version.

### Relaxed version constraints
Starting with this release, this Terraform module will move from a pessimistic constraint operator (`~>`) to a more relaxed provider version constraint (`>=`). As a result of this, module versions 8.0.0 and above can be used with newer (future) version of the Aviatrix Terraform provider, with the constraint that the newer provider version cannot have behavioral changes.
The reason for this change is to allow users to upgrade their controller and Terraform provider versions, without requiring to upgrade all their Terraform module versions, unless any of the following exceptions are true:
- User requires access to new feature flags, that are only exposed in newer Terraform module versions.
- The new Terraform provider version does not introduce behavior changes that are incompatible with the module version.

### Future releases
A new major module version will be released _only_ when:
- A new major Aviatrix Terraform provider has been released AND introduces new features or breaking changes.

A new minor module version will be released when:
- Bug fixes or missed features that were already available in the same release train as the Aviatrix Terraform provider.

## v1.6.0

### Add support for Aviatrix controller version 7.2 and Terraform provider version 3.2.x.

## v1.5.4
- Add support for BYO VNET that was added in the mc-transit module. Requires mc-transit version 2.5.2 or higher.
- Add outputs for `egress_vpc` and `management_vpc`.

## v1.5.3
- Add tags for the `aviatrix_firewall_instance` resources to the ignore_changes list, to prevent accidental replacement. Use `terraform taint` if you deliberatly want to replace an instance.

## v1.5.2
- Add support for configuring hashing algorithm
- Changed subnet number for Azure central FQDN deployment

## <del>v1.5.1</del> - Withdrawn due to unplanned keepalive behavior
- <del>Add support for configuring hashing algorithm</del>
- <del>Changed subnet number for Azure central FQDN deployment</del>

## v1.5.0
- Compatibility with controller version 7.1 and Terraform provider version 3.1.x

## v1.4.3
- Add ignore lifecycle statement to VPC DNS setting for FQDN egress.

## v1.4.2
- Removed support for Azure image ID.

## v1.4.1
- Fix issue where password was nullable.

## v1.4.0
- 7.0 / 3.0.x compatibility

## v1.3.0
- 6.9 / 2.24.x compatibility
- Add support for ssh_public_key and sic_key arguments

## v1.2.0
- Made module compatible with controller version 6.8 and provider version 2.23.x.
- Remove option to configure fail close. Provider [no longer supports this](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/latest/docs/guides/release-notes#enhancements) and will automatically default to true.

## v1.1.2
- GWLB usage is automatically detected from the transit module. As a result variable `use_gwlb` has been removed and needs to be removed from your module arguments when upgrading to this version.

## v1.1.1
- Add support for deploying Aviatrix FQDN egress filtering gateways in Azure and GCP.
    - Known issue: Azure firenet subnets are not created deterministically, causing potential issue with deploying FQDN gateway in the wrong subnet.
- Automatically truncate VPC name to 30 characters

## v1.1.0
- Made module compatible with controller version 6.7 and provider version 2.22.x.
- Made firewall instance association conditional with new boolean argument `associated`.
- Resolved a bug where FQDN egress gateways could not be deployed in other clouds than AWS.

## v1.0.2
- Fixed a bug where firewall instances in Azure were not deployed to AZ's (Credits: Andreas Krummrich, SVA)

## v1.0.1
- Add examples
- Add input validation for fw_amount
- Change variables with a default value to non-nullable to prevent overwriting internal logic when setting input to null on partent/root module.

## v1.0.0
Initial release