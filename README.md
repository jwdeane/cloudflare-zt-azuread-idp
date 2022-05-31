# Add Azure AD as a Zero Trust IdP

✨ Setup an Azure AD IdP for FREE, no credit card required ✨

This demo is based (and expands) on the public [Cloudflare developer docs guide](https://developers.cloudflare.com/cloudflare-one/identity/idp-integration/azuread/) for setting up an Azure AD IdP for use with Access. It also borrows heavily from the Hashicorp [Azure AD guide](https://learn.hashicorp.com/tutorials/terraform/azure-ad).

By applying this Terraform configuration _most_ components of the aforementioned guide can be automated for stand-up / tear-down.

At the end of this demo you will have:

- In **Azure**:
  - An Azure AD Directory
  - An Azure AD Application
  - A `Custom Domain` associated with your Directory
  - A collection of `Azure AD Users` as defined in [users.csv](./users.csv)
  - A collection of `Azure AD Groups` based on Department + Job Title in [users.csv](./users.csv)
- In **Cloudflare**:
  - A `TXT` record in your Zone for verifying ownership of the `Azure AD Custom Domain`
  - A simple Worker that echos back the request path (see [script.js](./script.js)) when visiting your demo Zone (as defined in the `cloudflare_zone` variable)
  - A Zero Trust `Access Application Catch-all` locking down your demo Zone (requires Azure IdP authentication to view)
  - A collection of `Access Groups` with a direct relation to the provisioned `Azure AD Groups`
  - A Zero Trust `Access Application for Managers` at `/managers/` with access restricted to the `Managers` Access Group (requires Azure IdP authentication by a user in the `Managers` group)

⭐️ Before getting started, copy [terraform.tfvars.example](./terraform.tfvars.example) to `terraform.tfvars` and pre-populate the Cloudflare variables.

```
cp terraform.tfvars.example terraform.tfvars
```

> 🚨 **NOTE**: the template assumes you'll be using your `Global API Key` to authenticate with the Cloudflare API. Security best practice would be to use an appropriately [scoped API Token](https://developers.cloudflare.com/api/tokens/create/) instead. See the `Getting Started` section in the [Cloudflare API Docs](https://api.cloudflare.com/#getting-started-requests) for more information.
>
> The `terraform.tfvars` file will house **secrets** and is included in `.gitignore` to prevent accidental commitment to version control.

## Pre-requisites

1. This process has only been tested on MacOS
   - [brew](https://brew.sh/) with `jq` and `terraform` installed (`brew install jq terraform`)
1. A Cloudflare Account with:
   - a configured Zero Trust [Team domain](https://developers.cloudflare.com/cloudflare-one/faq/teams-getting-started-faq/)
     - once configured set the **Team domain** in `./terraform.tfvars`, e.g.
     ```
     cloudflare_zero_trust_team_domain = "TEAM_NAME.cloudflareaccess.com"
     ```
   - an active [Workers account](https://developers.cloudflare.com/workers/get-started/guide/#1-sign-up-for-a-workers-account) (the `Free` plan is fine)
1. A Microsoft account (manual)
1. A free Azure AD Directory (manual)
   - a `Custom Domain` added to the directory

### Create a free Microsoft Account

> 💡 NOTE: you can skip this step if you already have a Microsoft account that you'd like to use.

1. Visit https://login.microsoftonline.com
1. Select the option to create a new account
   - e.g. create a new `xxx@outlook.com` account where `xxx` equals the Zone to be used in the demo
1. (recommended) secure your account by enabling two-step verification at [Account Security](https://account.microsoft.com/security)

### Setup a free Azure AD Directory

> 🚨 The Azure Portal has major issues in non-Chromium browsers!

1. Login to https://portal.azure.com with your Microsoft account
1. Navigate to `Manage Azure Active Directory`
   - A `Default Directory` will already be provisioned.
   - (optional) select `Properties` and change name to `Cloudflare Demo`
1. Copy the `Tenant ID` and save in [terraform.tfvars](./terraform.tfvars) as the `azure_arm_tenant_id` variable value.

### Setup Azure CLI

Install the Azure CLI and authenticate.

```
brew install az
az login --allow-no-subscriptions"
```

Once authenticated Terraform will [use the CLI to authenticate](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/azure_cli#configuring-azure-cli-authentication-in-terraform) `plan` or `apply` runs.

## Terraform the resources

Run `terraform init` to install the providers defined in [versions.tf](./versions.tf).

### First create the AD Users

> ⚠️ If you want to create your own users simply update [users.csv](./users.csv).

If you try and run `terraform plan|apply` now you'll see a collection of errors as below:

```
│ Error: Invalid for_each argument
│
│   on groups.tf line 7, in resource "azuread_group_member" "education":
│    7:   for_each = { for u in azuread_user.users : u.mail_nickname => u if u.department == "Education" }
│     ├────────────────
│     │ azuread_user.users is object with 6 attributes
│
│ The "for_each" map includes keys derived from resource attributes that cannot be determined until apply, and so Terraform cannot determine the full set of keys that
│ will identify the instances of this resource.
│
│ When working with unknown values in for_each, it's better to define the map keys statically in your configuration and place apply-time results only in the map
│ values.
│
│ Alternatively, you could use the -target planning option to first apply only the resources that the for_each value depends on, and then apply a second time to fully
│ converge.
```

⭐️ This is because you need to create the AD Users _before_ the AD Groups as group membership depends on the `member_object_id` that's only known after user creation has occurred.

To create the users, first run a [targetted apply](https://learn.hashicorp.com/tutorials/terraform/resource-targeting):

```
terraform plan -target="azuread_user.users"
terraform apply -target="azuread_user.users"
```

After the user creation has completed you can query the `terraform.tfstate` to retrieve the usernames and passwords:

```
jq '.resources[] | select( .type == "azuread_user" ) | .instances[].attributes | { user_principal_name, password }' terraform.tfstate
```

### 🚀 Create the remaining resources

With the Users in place you're now ready to run `terraform plan` and `terraform apply` to create the remaining resources.

```
terraform plan
terraform apply
```

Done! Visit your Zone in browser and you should be prompted to authenticate with your Azure IdP 🔐
