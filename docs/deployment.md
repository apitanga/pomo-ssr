# Deployment Guide

## Local Deployment

### Prerequisites

- AWS CLI configured with credentials
- jq installed (`apt-get install jq` or `brew install jq`)
- Node.js 20+

### Steps

```bash
# 1. Ensure infrastructure is deployed
# 2. Copy terraform outputs to config/
cp ~/infra/terraform.tfstate.d/prod/infra-outputs.json config/

# 3. Run deployment script
./scripts/deploy.sh
```

## CI/CD Deployment

### Automatic Deployment

Pushes to `main` branch automatically trigger deployment via GitHub Actions.

### Manual Deployment

Run the workflow manually from the Actions tab.

## Troubleshooting

### "Infrastructure config not found"

Run `terraform output -json > config/infra-outputs.json` from your infra directory.

### "AWS credentials not found"

Ensure AWS CLI is configured or set environment variables:
```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_REGION=us-east-1
```

### Lambda update fails

- Check that S3 bucket exists
- Verify Lambda function name matches output
- Ensure IAM permissions allow `lambda:UpdateFunctionCode`
