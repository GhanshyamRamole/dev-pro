variable "env" {}
variable "AWS_REGION" {}
variable "vpc_cidr" {}
variable "subnet_cidr" {}
variable "az" {}
variable "AWS_AMI" {}
variable "key" {
    default = "New"
}
variable "passwd" {
    default = "111"
}

variable "ansible_script_path" {
  description = "Path to the environment-specific ansible script"
  type        = string
}

# Count Switches
variable "ansible_count" { default = 0 }
variable "docker_count" { default = 0 }
variable "swarm_master_count" { default = 0 }
variable "swarm_worker_count" { default = 0 }
variable "k8s_count" { default = 0 }
