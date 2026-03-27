# 🚀 AgentXport — Blog Platform

A Gen-Z vibe blog platform built on a 3-tier architecture with a full DevSecOps implementation.

![React](https://img.shields.io/badge/React-18-61DAFB?style=flat-square&logo=react)
![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=flat-square&logo=node.js)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql)
![Terraform](https://img.shields.io/badge/Terraform-1.10-7B42BC?style=flat-square&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.32-326CE5?style=flat-square&logo=kubernetes)

---

## ✨ Features

- 📝 Create blog posts with emoji vibes
- ✏️ Edit your existing posts
- 🗑️ Delete posts you're not feeling anymore
- 💬 Comment on posts
- 🎨 Gen-Z dark UI with glassmorphism and gradients

---

## 🏗️ Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend   │────▶│   Backend    │────▶│  PostgreSQL  │
│  (React +    │◀────│  (Node.js +  │◀────│              │
│   Nginx)     │     │   Express)   │     │              │
│   Port 80    │     │  Port 5000   │     │  Port 5432   │
└──────────────┘     └──────────────┘     └──────────────┘
```

---

## 📁 Project Structure

```
agentxport-blogsite/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml           # App pipeline: lint → build → scan → deploy
│       └── infra.yml           # Infra pipeline: checkov → plan → apply
├── backend/                    # Node.js Express API
│   ├── src/
│   └── Dockerfile
├── frontend/                   # React (Vite) + Nginx
│   ├── src/
│   ├── nginx.conf
│   └── Dockerfile
├── k8s/
│   ├── base/                   # Kustomize base manifests
│   │   ├── backend/
│   │   ├── frontend/
│   │   ├── database/
│   │   ├── storage/
│   │   └── networkpolicy/
│   └── overlays/               # Per-environment overrides
│       ├── dev/
│       ├── staging/
│       └── prod/
├── terraform/
│   ├── modules/                # Reusable Terraform modules
│   │   ├── vpc/
│   │   └── eks/
│   └── live/                   # Terragrunt environment configs
│       ├── terragrunt.hcl      # Root: shared backend + provider
│       ├── dev/
│       ├── staging/
│       └── prod/
├── deploy/                     # EC2 bare-metal deployment scripts
└── docker-compose.yml          # Local development
```

---

## 🌿 Branching Strategy

```
feature/* ──┐
hotfix/*  ──┤──▶ develop ──▶ staging ──▶ main
            │
            └── PR required for all merges
```

| Branch | Environment | Infra Action | App Action |
|--------|-------------|--------------|------------|
| `feature/*` | — | plan only | lint + build + scan |
| `hotfix/*` | — | plan only | lint + build + scan |
| `develop` | dev | plan + apply | build + update dev overlay |
| `staging` | staging | plan + apply | build + update staging overlay |
| `main` | prod | plan + apply | build + update prod overlay |

---

## 🔐 GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM user access key for Terraform + EKS |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `AWS_REGION` | Target AWS region (e.g. `eu-central-1`) |

> `GITHUB_TOKEN` is provided automatically by GitHub Actions.

### GitHub Environments

Create 3 environments in `Settings → Environments`:
- `dev`
- `staging`
- `prod` — add required reviewers for manual approval gate before apply

---

## ☁️ Infrastructure (Terragrunt + EKS Auto Mode)

### Prerequisites

Before running the infra pipeline, the S3 backend must exist:

```bash
aws s3api create-bucket \
  --bucket agentxport-terraform-state \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1

aws dynamodb create-table \
  --table-name agentxport-tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-central-1
```

### Manual Terragrunt commands

```bash
# Plan a specific environment
cd terraform/live/dev
terragrunt run-all plan

# Apply a specific environment
cd terraform/live/staging
terragrunt run-all apply

# Destroy (careful!)
cd terraform/live/dev
terragrunt run-all destroy
```

### Configure kubectl after apply

```bash
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name agentxport-eks-<env>
```

---

## 🐳 Local Development

```bash
docker compose up --build
```

App available at `http://localhost`

---

## ☸️ Kubernetes Deployment (Kustomize)

```bash
# Apply a specific environment
kubectl apply -k k8s/overlays/dev
kubectl apply -k k8s/overlays/staging
kubectl apply -k k8s/overlays/prod
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/posts` | Get all posts |
| GET | `/api/posts/:id` | Get single post with comments |
| POST | `/api/posts` | Create a new post |
| PUT | `/api/posts/:id` | Update a post |
| DELETE | `/api/posts/:id` | Delete a post |
| GET | `/api/comments/post/:postId` | Get comments for a post |
| POST | `/api/comments` | Create a comment |
| DELETE | `/api/comments/:id` | Delete a comment |

---

## 🔒 Security Highlights

- Container images pinned to SHA256 digests
- All containers run as non-root
- `readOnlyRootFilesystem: true` on backend and frontend
- All capabilities dropped (`capabilities.drop: [ALL]`)
- NetworkPolicies enforce strict pod-to-pod traffic rules
- EKS secrets encrypted at rest with KMS
- Trivy image scanning on every build
- Checkov IaC scanning on every Terraform change
- Hadolint Dockerfile linting on every build
- S3 Terraform state encrypted with DynamoDB locking
