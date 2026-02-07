#!/bin/bash
# Deploy script for Serverless SSR App

set -e

CONFIG_FILE="${INFRA_CONFIG:-config/infra-outputs.json}"

# Verify config exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Infrastructure config not found: $CONFIG_FILE"
  echo ""
  echo "Setup required:"
  echo "  1. Deploy infrastructure from serverless-ssr-infra"
  echo "  2. Run: terraform output -json > $CONFIG_FILE"
  exit 1
fi

# Parse configuration
echo "📋 Loading configuration from $CONFIG_FILE"
PROJECT_NAME=$(jq -r '.app_config.value.project_name' "$CONFIG_FILE")
PRIMARY_REGION=$(jq -r '.app_config.value.primary_region' "$CONFIG_FILE")
DR_REGION=$(jq -r '.app_config.value.dr_region' "$CONFIG_FILE")
LAMBDA_PRIMARY=$(jq -r '.app_config.value.lambda.primary.function_name' "$CONFIG_FILE")
LAMBDA_DR=$(jq -r '.app_config.value.lambda.dr.function_name' "$CONFIG_FILE")
S3_BUCKET_PRIMARY=$(jq -r '.app_config.value.lambda.primary.s3_bucket' "$CONFIG_FILE")
S3_BUCKET_DR=$(jq -r '.app_config.value.lambda.dr.s3_bucket' "$CONFIG_FILE")
S3_STATIC=$(jq -r '.app_config.value.static_assets.s3_bucket' "$CONFIG_FILE")
CF_DIST_ID=$(jq -r '.app_config.value.cloudfront.distribution_id' "$CONFIG_FILE")

echo "🚀 Deploying $PROJECT_NAME"
echo "   Primary: $PRIMARY_REGION | DR: $DR_REGION"

# Build application
echo "🔨 Building application..."
cd app
rm -rf .output
NITRO_PRESET=aws-lambda npm install
NITRO_PRESET=aws-lambda npm run build

# Package Lambda code
echo "📦 Creating deployment package..."
cd .output/server
zip -r ../../lambda-deploy.zip .
cd ../..

# Upload to S3
echo "☁️ Uploading to S3..."
aws s3 cp lambda-deploy.zip "s3://${S3_BUCKET_PRIMARY}/lambda/function.zip"
if [ -n "$S3_BUCKET_DR" ] && [ "$S3_BUCKET_DR" != "null" ]; then
  aws s3 cp lambda-deploy.zip "s3://${S3_BUCKET_DR}/lambda/function.zip" --region "$DR_REGION"
fi

# Update Lambda functions
echo "🔄 Updating Lambda functions..."
aws lambda update-function-code \
  --function-name "$LAMBDA_PRIMARY" \
  --s3-bucket "$S3_BUCKET_PRIMARY" \
  --s3-key lambda/function.zip \
  --publish

if [ -n "$LAMBDA_DR" ] && [ "$LAMBDA_DR" != "null" ]; then
  aws lambda update-function-code \
    --function-name "$LAMBDA_DR" \
    --s3-bucket "$S3_BUCKET_DR" \
    --s3-key lambda/function.zip \
    --region "$DR_REGION" \
    --publish
fi

# Sync static assets
echo "🌐 Syncing static assets..."
aws s3 sync .output/public/ "s3://${S3_STATIC}/" \
  --delete \
  --cache-control "public, max-age=31536000, immutable"

# Invalidate CloudFront
echo "🧹 Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id "$CF_DIST_ID" \
  --paths "/_nuxt/*" "/favicon.ico" "/*.html"

echo "✅ Deployment complete!"
echo "   URL: $(jq -r '.application_url.value' "../$CONFIG_FILE")"
