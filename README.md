# Serverless SSR App Template

A Nuxt.js application template for serverless SSR deployment on AWS Lambda + CloudFront.

## Quick Start

### Prerequisites

1. **Infrastructure deployed** from [serverless-ssr-infra](https://github.com/apitanga/serverless-ssr-pattern/tree/modularize-infra)
2. AWS CLI configured with credentials
3. Node.js 20+

### Setup

```bash
# 1. Clone this template
git clone https://github.com/apitanga/serverless-ssr-app.git my-app
cd my-app

# 2. Install dependencies
npm install

# 3. Copy infrastructure outputs
# From your infra deployment directory:
# terraform output -json > ~/my-app/config/infra-outputs.json

# 4. Deploy
./scripts/deploy.sh
```

## Project Structure

```
.
├── app/                    # Nuxt application
│   ├── pages/             # Vue pages
│   ├── server/api/        # API routes
│   └── ...
├── config/
│   └── infra-outputs.json # Terraform outputs (gitignored)
├── scripts/
│   └── deploy.sh          # Deployment script
└── .github/workflows/
    └── deploy.yml         # CI/CD workflow
```

## Documentation

- [Infrastructure Setup](docs/infrastructure-setup.md)
- [Deployment Guide](docs/deployment.md)

## License

MIT
