
.
|-- TerraformEC2Policy                    # Directory containing an IAM policy definition, likely a `*.json` file. This policy grants permissions for the EC2 instance to interact with other AWS services.
|-- main.tf                               # The primary Terraform configuration file. It defines the AWS provider and the main resources to be created, such as the EC2 instance.
|-- outputs.tf                            # This file specifies which resource attributes (e.g., instance ID, public IP address) should be displayed in the console after Terraform finishes applying.
|-- terraform-ec2-key                     # A private SSH key file used to securely access the provisioned EC2 instance via SSH. **This is sensitive information and should not be committed to version control.**
|-- terraform-ec2-key.pub                 # The public portion of the SSH key. This key is embedded in the EC2 instance during provisioning to allow for SSH access.
|-- terraform.tfstate                     # Terraform's state file. This file tracks the real-world infrastructure created by your configuration. It's a critical file for Terraform to understand what resources exist and manage them. **DO NOT MODIFY MANUALLY.**
|-- terraform.tfstate.backup              # An automatic backup of the Terraform state file created by Terraform before it makes changes to the primary state file.
|-- terraform.tfvars                      # This file contains variable assignments for your configuration. It allows you to specify values (e.g., instance type, region) without modifying the `main.tf` file.
|-- user_data.sh                          # A shell script that is passed as "user data" to the EC2 instance. It runs during the instance's first boot to perform setup tasks like installing software or configuring the system.
`-- variables.tf                          # This file declares the input variables used in your Terraform configuration. It defines the variable names, data types, and can provide default values.
