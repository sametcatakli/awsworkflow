# AWS Workflow

AWS EC2 infrastructure deployed with Terraform and GitHub Actions.

## Architecture

- Terraform for infrastructure
- S3 backend for Terraform state
- GitHub Actions for CI/CD
- EC2 Ubuntu 22.04 LTS instance with nginx

## Prerequisites

- AWS account with programmatic access
- AWS CLI configured
- Terraform >= 1.6.0
- Admin access to GitHub repository

## Installation

### S3 Backend

```bash
aws s3api create-bucket \
  --bucket awsworkflow-tfstate-sametcatakli \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket awsworkflow-tfstate-sametcatakli \
  --versioning-configuration Status=Enabled
```

### GitHub Secrets

Configure in **Settings > Secrets and variables > Actions**:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (if using temporary credentials)

Required permissions: EC2, S3

## Usage

### Automatic Deployment

Workflow runs automatically on push to `main` when files in `terraform/**` change.

### Manual Deployment

**Actions > Terraform Apply > Run workflow**

### Destroy

**Actions > Terraform Destroy > Run workflow**

Confirmation: enter `DESTROY`

## Local Commands

```bash
cd terraform
terraform init
terraform plan
terraform apply
terraform output
terraform destroy
```

## Variables

| Variable | Default |
|----------|---------|
| `aws_region` | `us-east-1` |
| `project_name` | `awsworkflow` |
| `instance_type` | `t3.micro` |
| `ssh_cidr` | `0.0.0.0/0` |
| `key_name` | `null` |

## Outputs

- `instance_public_ip`
- `instance_public_dns`

## Structure

```
terraform/
  versions.tf
  providers.tf
  backend.tf
  variables.tf
  main.tf
  outputs.tf
  user_data.sh
.github/workflows/
  terraform-apply.yml
  terraform-destroy.yml
```
