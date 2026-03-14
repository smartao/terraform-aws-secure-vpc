# Examples

This directory contains runnable examples that demonstrate how to consume the module from a local checkout.

## Available examples

- `simple.tf`: basic usage with one VPC, two public subnets, and two private subnets across two Availability Zones

## Running the basic example

From this directory:

```bash
cd examples
terraform init
terraform plan
```

The example in `simple.tf`:

- configures the AWS provider in `us-east-1`
- selects the first two available Availability Zones dynamically
- creates a development VPC using the local module source `../`

Before applying, make sure your AWS credentials are configured in the environment used by Terraform.
