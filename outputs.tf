output "master_public_ip" {
  description = "Public IP of Kubernetes master node"
  value       = aws_instance.k8s_master.public_ip
}

output "worker_public_ip" {
  description = "Public IP of Kubernetes worker node"
  value       = aws_instance.k8s_worker.public_ip
}

output "master_private_ip" {
  description = "Private IP of Kubernetes master node"
  value       = aws_instance.k8s_master.private_ip
}

output "worker_private_ip" {
  description = "Private IP of Kubernetes worker node"
  value       = aws_instance.k8s_worker.private_ip
}

output "security_group_id" {
  description = "ID of the Kubernetes security group"
  value       = aws_security_group.k8s_sg.id
}

output "ssh_master" {
  description = "SSH command to connect to master node"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.k8s_master.public_ip}"
}

output "ssh_worker" {
  description = "SSH command to connect to worker node"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.k8s_worker.public_ip}"
}
