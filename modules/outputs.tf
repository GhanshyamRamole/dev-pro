# --- ansible Control Plane Output ---
output "ansible_public_ip" {
  description = "Public IP of the Ansible Control Node"
  value       = aws_instance.ansible[*].public_ip
}

output "ansible_private_ip" {
  description = "Private IP of the Ansible Control Node"
  value       = aws_instance.ansible[*].private_ip
}

# --- Standalone Docker Output (Dev/Prod) ---
output "docker_standalone_ips" {
  description = "Private IPs of Standalone Docker Nodes"
  value       = aws_instance.docker[*].private_ip
}

# --- Docker Swarm Outputs (Stage) ---
output "swarm_master_ips" {
  description = "Private IPs of Docker Swarm Master Nodes"
  value       = aws_instance.swarm_master[*].private_ip
}

output "swarm_worker_ips" {
  description = "Private IPs of Docker Swarm Worker Nodes"
  value       = aws_instance.swarm_worker[*].private_ip
}

# --- Kubernetes Outputs (Prod) ---
output "kubernetes_node_public_ip" {
  description = "Public IP of the Kubernetes Server"
  value       = aws_instance.cluster[*].public_ip
}

output "kubernetes_node_private_ip" {
  description = "Private IP of the Kubernetes Server"
  value       = aws_instance.cluster[*].private_ip
}
