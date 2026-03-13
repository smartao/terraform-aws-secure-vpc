# 📦 terraform-aws-secure-vpc

Terraform module to provision a highly available VPC on AWS with public and private subnets distributed across multiple Availability Zones, Internet Gateway, and one NAT Gateway per AZ.

This module is designed for reuse through the HashiCorp Registry and exposes a small, objective interface for teams that need a secure baseline network for workloads running in private subnets.

## ⚙️ Features

- Creates a VPC with DNS support and DNS hostnames enabled
- Creates public and private subnets across multiple Availability Zones
- Creates an Internet Gateway for inbound and outbound internet access from public subnets
- Creates one Elastic IP and one NAT Gateway per public subnet/AZ for private subnet egress
- Creates public and private route tables and associates them with the correct subnets
- Applies consistent tags to all resources
- Validates CIDRs, Availability Zone uniqueness, and minimum subnet/AZ count

## 🏗️ Architecture

The module creates:

- 1 VPC
- N public subnets
- N private subnets
- 1 Internet Gateway
- N Elastic IPs
- N NAT Gateways
- 1 public route table
- N private route tables

Where `N` is the number of Availability Zones provided in `var.azs`.

## 🚀 Quick Start

```hcl
module "secure_vpc" {
  source = "sergei/secure-vpc/aws"

  name_prefix          = "prod-core"
  environment          = "production"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

## Requirements and Assumptions

- At least 2 Availability Zones must be provided
- `azs`, `public_subnet_cidrs`, and `private_subnet_cidrs` must have the same length
- Availability Zones must be unique
- Each subnet CIDR and the VPC CIDR must be valid CIDR blocks
- `name_prefix` must be 32 characters or fewer

## 🏷️ Tagging

All resources receive these baseline tags:

- `Environment = var.environment`
- `ManagedBy = Terraform`
- `Module = network`

In addition, each resource receives a specific `Name` tag, and subnets also receive a `Tier` tag with value `public` or `private`.

## 📤 Outputs

The module exposes the values most consumers need to integrate compute, databases, and other network-attached resources:

- VPC ID and CIDR block
- Public subnet IDs
- Private subnet IDs
- NAT Gateway IDs keyed by Availability Zone

## 📄 Operational Notes

- This module creates one NAT Gateway per Availability Zone to improve availability and keep private subnet routing local to each AZ.
- NAT Gateways and Elastic IPs incur AWS charges. Cost scales with the number of Availability Zones used.
- Public subnets are created with `map_public_ip_on_launch = true`.
- Private subnets do not assign public IPs on launch.

## 📜 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones to use | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag for resources | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming resources | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | A list of CIDR blocks for the private subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | A list of CIDR blocks for the public subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | Map of NAT Gateway IDs by Availability Zone |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | List of private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | List of public subnet IDs |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->
