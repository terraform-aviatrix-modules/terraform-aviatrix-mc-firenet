# terraform-aviatrix-mc-firenet release notes

## v1.0.2
- Fixed a bug where firewall instances in Azure were not deployed to AZ's (Credits: Andreas Krummrich, SVA)

## v1.0.1
- Add examples
- Add input validation for fw_amount
- Change variables with a default value to non-nullable to prevent overwriting internal logic when setting input to null on partent/root module.

## v1.0.0
Initial release