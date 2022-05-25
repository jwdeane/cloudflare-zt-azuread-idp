# CFLR.win

Management of the cflr.win demo Zone.

## Get Started

```
terraform init
terraform plan
terraform apply
```

### Configure Environment Variables

Update `terraform.tfvars.example` with appropriate variable values and rename the file to `terraform.tfvars`. As this file contains **secrets** it's listed in the repository `.gitignore` file to prevent accidental commits to version control.

### Authentication

🚨 **NOTE**: the template assumes you'll be using your `Global API Key` to authenticate with the Cloudflare API. This is **not** recommended. Security best practice would be to use an appropriately [scoped API Token](https://developers.cloudflare.com/api/tokens/create/).

You can also remove the API credential from the `terraform.tfvars` file entirely by setting a [shell environment variable](https://learn.hashicorp.com/tutorials/terraform/sensitive-variables?in=terraform/configuration-language#set-values-with-environment-variables) that Terraform will pickup and use at runtime, e.g.

```
export TF_VAR_cloudflare_api_key=ABC123
```
