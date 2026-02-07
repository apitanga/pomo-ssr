# Infrastructure Setup

Before deploying this application, you need to provision the AWS infrastructure.

## Option 1: Using the Serverless SSR Infra Module

### 1. Clone and Configure Infrastructure

```bash
git clone https://github.com/apitanga/serverless-ssr-pattern.git
cd serverless-ssr-pattern/terraform/examples/basic
```

### 2. Create terraform.tfvars

```hcl
project_name = "my-app"
domain_name  = "example.com"
subdomain    = "app"
environment  = "prod"

# Optional
create_ci_cd_user = true
enable_dr         = true
```

### 3. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 4. Export Outputs for App

```bash
terraform output -json > ~/my-app/config/infra-outputs.json
```

### 5. Get CI/CD Credentials (if created)

```bash
terraform output cicd_aws_access_key_id
terraform output cicd_aws_secret_access_key  # sensitive
```

## Required GitHub Secrets

Add these to your app repository:

| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | From `cicd_aws_access_key_id` output |
| `AWS_SECRET_ACCESS_KEY` | From `cicd_aws_secret_access_key` output |
| `AWS_PRIMARY_REGION` | e.g., `us-east-1` |
| `INFRA_OUTPUTS_JSON` | Contents of `infra-outputs.json` |

## Infrastructure Resources Created

- **Lambda Functions**: Primary and DR regions
- **CloudFront Distribution**: Global CDN with failover
- **S3 Buckets**: Static assets + Lambda deployment packages
- **DynamoDB**: Global table (optional)
- **IAM Roles**: Execution role + CI/CD user

## Next Steps

See [Deployment Guide](deployment.md) for application deployment.
