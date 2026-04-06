# Terraform - Sock Shop Kubernetes Infrastructure

Infrastructure as Code (IaC) for provisioning AWS resources required to run the Sock Shop microservices demo application on a self-managed Kubernetes cluster using kubeadm.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Resources Created](#resources-created)
- [Security Group Rules](#security-group-rules)
- [Variables](#variables)
- [Outputs](#outputs)
- [Usage](#usage)
- [Cost Estimate](#cost-estimate)
- [Related Repositories](#related-repositories)

---

## Overview

This repository contains Terraform code that provisions the complete AWS infrastructure needed for a 2-node Kubernetes cluster. Instead of manually clicking through the AWS Console, all infrastructure is defined as code — making it reproducible, version-controlled, and auditable.

**Why Terraform instead of manual AWS Console setup?**

| Manual AWS Console | Terraform |
|-------------------|-----------|
| No record of what was created | Every resource defined in code |
| Hard to reproduce exactly | Run terraform apply — identical setup every time |
| No audit trail | Full git history of every infrastructure change |
| Error-prone when repeated | Automated — no human error |
| Difficult to share with team | Clone repo and apply |

---

## Architecture

```
AWS Region: ap-south-1 (Mumbai)
│
├── Security Group: sockshop-k8s-sg
│   ├── Inbound: SSH (22), K8s API (6443), etcd (2379-2380)
│   ├── Inbound: Kubelet (10250-10252), NodePort (30000-32767)
│   ├── Inbound: Jenkins (8080), Internal cluster traffic
│   └── Outbound: All traffic allowed
│
├── EC2 Instance: sockshop-k8s-master (t2.medium)
│   ├── Role: Kubernetes control plane
│   ├── Runs: kube-apiserver, etcd, kube-scheduler, kube-controller-manager
│   ├── Runs: Jenkins CI server
│   └── Storage: 20GB gp2
│
└── EC2 Instance: sockshop-k8s-worker (t2.medium)
    ├── Role: Kubernetes worker node
    ├── Runs: All Sock Shop application pods (14 microservices)
    ├── Runs: Prometheus, Grafana monitoring stack
    └── Storage: 20GB gp2
```

---

## Prerequisites

Before running Terraform, ensure you have:

- **Terraform** >= 1.0 installed
- **AWS CLI** configured with valid credentials
- An existing **AWS Key Pair** in the ap-south-1 region
- IAM user with permissions: EC2FullAccess or equivalent

**Install Terraform (Ubuntu):**
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform --version
```

**Configure AWS credentials:**
```bash
aws configure
# Enter Access Key ID, Secret Access Key, region: ap-south-1, output: json
aws sts get-caller-identity  # Verify credentials work
```

---

## Project Structure

```
terraform-sockshop/
├── provider.tf       # AWS provider configuration and Terraform version constraints
├── variables.tf      # Input variables — region, instance type, AMI, key pair
├── main.tf           # Core resources — security group, EC2 instances
├── outputs.tf        # Output values — public IPs, private IPs, SSH commands
├── .gitignore        # Excludes .terraform/, state files, large binaries
└── README.md         # This file
```

---

## Resources Created

| Resource | Name | Type | Purpose |
|----------|------|------|---------|
| Security Group | sockshop-k8s-sg | aws_security_group | Firewall rules for both nodes |
| EC2 Instance | sockshop-k8s-master | aws_instance | Kubernetes control plane + Jenkins |
| EC2 Instance | sockshop-k8s-worker | aws_instance | Application workloads + Monitoring |

**Total resources: 3**

---

## Security Group Rules

### Inbound Rules

| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH access to nodes |
| 6443 | TCP | Kubernetes API server |
| 2379-2380 | TCP | etcd key-value store |
| 10250-10252 | TCP | Kubelet API |
| 30000-32767 | TCP | NodePort services (Sock Shop, Argo CD, Grafana) |
| 8080 | TCP | Jenkins CI server |
| All | All | Internal cluster communication (self-referencing rule) |

### Outbound Rules

| Port | Protocol | Purpose |
|------|----------|---------|
| All | All | Allow all outbound traffic |

---

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| aws_region | ap-south-1 | AWS region to deploy infrastructure |
| instance_type | t2.medium | EC2 instance type for both nodes |
| ami_id | Ubuntu 22.04 AMI | AMI ID for ap-south-1 region |
| key_name | your-key-pair-name | Existing AWS key pair name for SSH |
| project_name | sockshop | Used as prefix for all resource names and tags |

**To override defaults, create a terraform.tfvars file:**
```hcl
aws_region    = "ap-south-1"
instance_type = "t2.medium"
key_name      = "my-actual-key-pair"
project_name  = "sockshop"
```

> Note: terraform.tfvars is excluded from git via .gitignore to protect sensitive values.

---

## Outputs

After `terraform apply` completes, the following values are printed:

| Output | Description |
|--------|-------------|
| master_public_ip | Public IP of master node — used to access Jenkins |
| master_private_ip | Private IP of master node — used for kubeadm join |
| worker_public_ip | Public IP of worker node — used to access Sock Shop, Grafana |
| worker_private_ip | Private IP of worker node |
| security_group_id | ID of the created security group |
| ssh_master | Ready-to-use SSH command for master node |
| ssh_worker | Ready-to-use SSH command for worker node |

**Example output:**
```
master_public_ip = "13.233.x.x"
worker_public_ip = "13.234.x.x"
ssh_master = "ssh -i your-key.pem ubuntu@13.233.x.x"
ssh_worker = "ssh -i your-key.pem ubuntu@13.234.x.x"
```

---

## Usage

### Step 1 — Initialize Terraform
Downloads the AWS provider plugin.
```bash
terraform init
```

### Step 2 — Preview changes
Shows exactly what will be created without making any changes.
```bash
terraform plan
```

### Step 3 — Apply (create infrastructure)
Creates all resources. Type `yes` when prompted.
```bash
terraform apply
```

### Step 4 — After infrastructure is created
Use the output IPs to:
1. SSH into master and worker nodes
2. Run kubeadm to set up the Kubernetes cluster
3. Deploy Sock Shop application
4. Set up Jenkins, Argo CD, Prometheus, Grafana

Refer to the [sockshop-gitops](https://github.com/sandeepcharan-devops/sockshop-gitops) repository for complete deployment steps.

### Step 5 — Destroy (when done)
Terminates all created resources. Type `yes` when prompted.
```bash
terraform destroy
```

> Warning: This permanently deletes all EC2 instances and the security group. All data on the instances will be lost.

---

## Cost Estimate

| Resource | Type | Cost |
|----------|------|------|
| EC2 Master | t2.medium | ~$0.046/hour |
| EC2 Worker | t2.medium | ~$0.046/hour |
| EBS Storage | 2 x 20GB gp2 | ~$0.10/GB/month |
| **Total running** | | **~$0.092/hour** |
| **Total if run 6hrs/day** | | **~$8-10/month** |

**Cost control tip:** Stop EC2 instances when not working. Stopped instances do not incur compute charges.

```bash
# Stop instances to save cost (via AWS Console or CLI)
aws ec2 stop-instances --instance-ids <master-id> <worker-id>

# Start instances when resuming work
aws ec2 start-instances --instance-ids <master-id> <worker-id>
```

---

## Related Repositories

| Repository | Purpose |
|------------|---------|
| [front-end](https://github.com/sandeepcharan-devops/front-end) | Hardened Dockerfile, Jenkins CI pipeline, CVE remediation |
| [sockshop-gitops](https://github.com/sandeepcharan-devops/sockshop-gitops) | Kubernetes manifests, Helm charts, Argo CD GitOps |
| [terraform-sockshop](https://github.com/sandeepcharan-devops/terraform-sockshop) | This repo — AWS infrastructure as code |

---

## Key Learnings

- **Infrastructure as Code** — all AWS resources defined in version-controlled Terraform files instead of manual console clicks
- **Separation of concerns** — infrastructure code lives separately from application and GitOps code
- **Reproducibility** — identical infrastructure can be recreated in any AWS account by running terraform apply
- **Security Group as code** — all firewall rules documented and version-controlled, no manual port additions
- **Output values** — instance IPs printed automatically after apply, no need to check AWS Console
