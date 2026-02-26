
variable "env" {
  type = string
}

variable "AWS_REGION" {
  type = string
}

variable "AWS_AMI" {
  type = string
}

variable "az" {
  type = string
}

variable "key" {
  type = string
}

variable "passwd" {
  type = string
}

# Instance Counts
variable "ansible_count" {
  type    = number
  default = 0
}

variable "docker_count" {
  type    = number
  default = 0
}

variable "swarm_master_count" {
  type    = number
  default = 0
}

variable "swarm_worker_count" {
  type    = number
  default = 0
}

variable "k8s_count" {
  type    = number
  default = 0
}
