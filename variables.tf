variable "aws_region" {
  description = "AWS region to deploy infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for Kubernetes nodes"
  type        = string
  default     = "t2.medium"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for ap-south-1"
  type        = string
  default     = "ami-0ec10929233384c7f"
}

variable "key_name" {
  description = "Name of existing AWS key pair for SSH access"
  type        = string
  default     = "My-Project1"
}

variable "project_name" {
  description = "Project name used for tagging resources"
  type        = string
  default     = "sockshop"
}
