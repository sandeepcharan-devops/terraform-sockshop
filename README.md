# Terraform - Sock Shop Kubernetes Infrastructure

Provisions the AWS infrastructure for the Sock Shop Kubernetes cluster.

## Resources Created

| Resource | Details |
|----------|---------|
| EC2 Master | t2.medium, Ubuntu 22.04 |
| EC2 Worker | t2.medium, Ubuntu 22.04 |
| Security Group | All Kubernetes required ports |

## Usage
```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

## Outputs

After apply, Terraform prints master and worker public IPs and SSH commands.
