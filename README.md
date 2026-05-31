# 🚀 terraform-gitops-simple

**GitOps + AI for Terraform** — Simple working setup based on TechWorld with Nana's  
*"5 Stages of Infrastructure Management"* (Stage 4: GitOps + Stage 5: AI-Assisted).

> **Owner:** mrbalraj007 | **Stack:** AWS · Terraform · GitHub Actions  
> **Region:** us-east-1 (Sydney)

---

## 🗺️ How It Works

```
You / AI writes Terraform code
        ↓
  git push → Pull Request
        ↓
  GitHub Actions → terraform plan  (auto, on PR open)
  Plan output posted as PR comment
        ↓
  Review → Merge PR to main
        ↓
  GitHub Actions → terraform apply  (auto, on merge)
        ↓
  AWS infrastructure updated  ✅
```

**Nobody runs `terraform apply` locally. Git is the only path to production.**

---

## 📁 Repo Structure

```
terraform-gitops-simple/
├── .github/
│   ├── pull_request_template.md      # PR checklist for Terraform changes
│   └── workflows/
│       ├── terraform-plan.yml        # Runs on every PR → posts plan as comment
│       ├── terraform-apply.yml       # Runs on merge to main → auto apply
│       └── terraform-destroy.yml     # Manual trigger only (safety gate)
│
├── modules/
│   └── s3/                           # Reusable S3 module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/
│   ├── dev/dev.tfvars                # Dev-specific variable values
│   └── prod/prod.tfvars              # Prod-specific variable values
│
├── scripts/
│   └── bootstrap.sh                  # One-time: creates S3 state bucket
│
├── main.tf                           # Root module — calls child modules
├── variables.tf                      # Input variable declarations
├── outputs.tf                        # Output values
├── backend.tf                        # Remote state config (S3)
└── .gitignore
```

---

## ⚡ Quick Start — First-Time Setup

### 1. Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Terraform | ≥ 1.8.0 | https://developer.hashicorp.com/terraform/install |
| AWS CLI | v2 | https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html |
| Git | any | https://git-scm.com |

### 2. Clone the repo

```bash
git clone https://github.com/mrbalraj007/terraform-gitops-simple
cd terraform-gitops-simple
```

### 3. Bootstrap the remote state bucket (one-time only)

This creates the S3 bucket that stores your `terraform.tfstate` remotely.

```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

Expected output:
```
✅  Bootstrap complete!
    Bucket : s3://mrbalraj-tfstate-gitops
```

### 4. Add GitHub Secrets

Go to: `GitHub repo → Settings → Secrets and variables → Actions → New repository secret`

| Secret Name | Value |
|-------------|-------|
| `AWS_ACCESS_KEY_ID` | Your IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | Your IAM user secret key |

> 💡 **Tip for later:** Replace static keys with OIDC for keyless auth  
<!-- > (you've already done this pattern for TGE — same approach applies here) -->

### 5. Verify local setup

```bash
terraform init
terraform validate
terraform plan -var-file="environments/dev/dev.tfvars"
```

All three should pass cleanly. **Do not run `terraform apply` locally.**

---

## 🔄 Day-to-Day GitOps Workflow

### Making a change (the GitOps way)

```bash
# Step 1: Create a feature branch
git checkout -b feat/add-my-resource

# Step 2: Write or paste Terraform code (can use AI to generate)
# Edit main.tf, add a new module call, etc.

# Step 3: Format and validate locally (optional but good habit)
terraform fmt -recursive
terraform validate

# Step 4: Commit and push
git add .
git commit -m "feat: add xyz resource"
git push origin feat/add-my-resource

# Step 5: Open a Pull Request on GitHub
# → GitHub Actions automatically runs terraform plan
# → Plan output appears as a comment on the PR

# Step 6: Review the plan comment, then merge
# → GitHub Actions automatically runs terraform apply
# → Infrastructure is updated in AWS ✅
```

---

## 🤖 Stage 5: Using AI to Write Terraform (the AI-GitOps loop)

This is Stage 5 from the video. The process is:

```
Ask AI → Get Terraform code → Paste into branch → PR → Plan → Merge → Apply
```

### Example prompts to use with Claude / Copilot

**Add a new S3 bucket:**
```
Write Terraform code to call the existing ./modules/s3 module
with a new bucket named "mrbalraj-gitops-logs-us-east-1",
versioning enabled, encryption enabled, public access blocked.
Add it to main.tf.
```

**Add an EC2 instance:**
```
Write a Terraform module in ./modules/ec2 for a t3.micro EC2 instance
in us-east-1, using Amazon Linux 2023 latest AMI (dynamic lookup),
with a Name tag and environment tag. Include variables.tf and outputs.tf.
```

**Review existing code:**
```
Review this Terraform code for security issues, missing tags,
and best practices. [paste your .tf file]
```

---

## 🔧 GitHub Actions Workflows

### terraform-plan.yml (PR trigger)

Runs on every PR that touches `.tf` or `.tfvars` files.

| Step | What it does |
|------|-------------|
| `fmt -check` | Ensures code is properly formatted |
| `init` | Initialises Terraform and downloads providers |
| `validate` | Checks config syntax |
| `plan` | Generates execution plan |
| PR comment | Posts plan output (with emoji status table) back to the PR |

### terraform-apply.yml (merge to main trigger)

Runs automatically when a PR is merged to `main`.

| Step | What it does |
|------|-------------|
| `init` | Re-initialises (clean runner) |
| `plan` | Re-generates plan as final confirmation |
| `apply -auto-approve` | Applies the plan to AWS |
| GitHub Issue | Auto-creates a bug issue if apply fails |

### terraform-destroy.yml (manual only)

**Requires manual trigger** via `Actions → terraform-destroy → Run workflow`.  
You must type `DESTROY` in the confirmation field — prevents accidents.

---

## 🔒 Security Notes

- State file is stored encrypted in S3 (`AES-256`)
- No secrets are stored in code — all via GitHub Secrets
- Public access is blocked on all S3 buckets
- `.gitignore` prevents accidental commit of `.tfstate` files

---

## 🚀 What to Build Next (Complex Setup)

Once this simple setup is working, extend it in this order:

| Phase | What to add |
|-------|-------------|
| 1 | Replace static AWS keys with **OIDC** (keyless auth) |
| 2 | Add **Checkov** security scanning to the plan job |
| 3 | Add **Slack notifications** on apply success/failure |
| 4 | Add **multi-environment matrix** (dev + prod in parallel) |
| 5 | Add **drift detection** (nightly cron plan job) |
| 6 | Add **Terragrunt** for DRY multi-account management |

---

## 📚 References

- [TechWorld with Nana — 5 Stages Video](https://youtu.be/iTrxsotFNHA)
- [HashiCorp Terraform Docs](https://developer.hashicorp.com/terraform/docs)
- [GitHub Actions for Terraform](https://github.com/hashicorp/setup-terraform)
- [AWS Actions — configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
