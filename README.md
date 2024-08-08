<h2>Cyber DigitalOcean</h2>

<p align="center">
    <img alt="License" src="https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge" />
    <img alt="DigitalOcean" src="https://img.shields.io/badge/DigitalOcean-0080FF?logo=digitalocean&logoColor=fff&style=for-the-badge" />
    <img alt="Shell Script" src="https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white" />
    <img alt="Github Action " src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" />
</p>

Just like the Cybermans, _Delete_ resources from your DigitalOcean account.

This project is inspired by what is <a href="https://github.com/rebuy-de/aws-nuke" target="_blank">aws-nuke</a> for automatic resource removal from an cloud provider account. And completely based on my other project, the [dalek-linode](https://github.com/ciro-mota/dalek-linode).

## ⚠️ Caution!

Be aware of the risks, you should not use this script in a production account.

To reduce the range and mitigate some problems there are some safety precautions:

1. By default only a few [paid features](https://www.digitalocean.com/pricing) are covered by this script: Droplets (VMs), Kubernetes, Volumes, Databases and NodeBalancers.

2. Also by default, the script will check for the existence of tags with the string name `prod` or related tags and will ignore removing the resource that is associated with this tag.

3. This script will not read or remove any other resources than those listed above.

> [!IMPORTANT]\
> It is not possible to locate Databases via CLI using tags, although it is possible to insert them through the web admin, this tool will then check for the presence of tags with the string name `prod` or related **in the DB name** to determine whether it will be removed or not.

> [!NOTE]\
> Spaces (S3) are not covered due to the characteristics of the function.

## 💸 Use Cases

DigitalOcean charges you for the use of VMs [even if they are in a powered off state](https://www.digitalocean.com/pricing/droplets#general-faq) and this can cause a huge cost issue for some people. So you can never simply forget to remove your instances after some testing. Including your tests with [Terraform](https://www.terraform.io/) that may have failed to apply or you forgot to `destroy` when finished.

With this script your resources will be deleted days at a time pre-scheduled by you with the help of GitHub actions.

## 🚀 Installation

- Create a [DigitalOcean Personal Access Token](https://docs.digitalocean.com/reference/api/create-personal-access-token/).
- Name it.
- Clone this repo.
- Create a repository secret (`Settings` » `Secret and variables` » `Actions` » `New repository secret`) named `DO_TOKEN` and insert your DigitalOcean Personal Access Token.

## 💻 Usage

- Edit the `do-nuke.yml` uncommenting lines `4` and `5` and adjust the period in which you want the removal action to be performed. By default it will run daily at 3:33am.

```
schedule:
  - cron: "33 3 * * *"
```

## 🐳 Docker

You can also use a Docker container to run the script manually when you want.

- Clone this repo.
- In the Dockerfile file, edit the `DO_CLI_TOKEN` variable and insert your DigitalOcean Personal Access Token.
- Build.
- Exec.

## 🤝 Referral

Need fast and affordable cloud hosting? Try @digitalocean using my affiliate link and get free credits to get started:

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=0f7a4359d994&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

## 🎁 Sponsoring

If you like this work, give me it a star on GitHub, and consider supporting it buying me a coffee:

[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/donate/?business=VUS6R8TX53NTS&no_recurring=0&currency_code=USD)
