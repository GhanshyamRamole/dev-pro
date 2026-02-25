# --- Ansible Server Outputs ---
output "ansible_public_ip" {
  description = "Public IP address of the Ansible Control Node"
  value       = aws_instance.ansible.public_ip
}

output "ansible_private_ip" {
  description = "Private IP address of the Ansible Control Node"
  value       = aws_instance.ansible.private_ip
}

# --- Node Cluster Outputs (Dynamic) ---
output "docker_public_ips" {
  description = "List of Public IPs for all managed nodes"
  value       = aws_instance.docker.public_ip
}

output "docker_private_ips" {
  description = "List of Private IPs for all managed nodes"
  value       = aws_instance.docker.private_ip
}


output "cluster_public_ips" {
  description = "List of Public IPs for all managed nodes"
  value       = aws_instance.cluster.public_ip
}

output "cluster_private_ips" {
  description = "List of Private IPs for all managed nodes"
  value       = aws_instance.cluster.private_ip
}

