module "stag_infrastructure" {
  source = "../../modules"

  env           = var.env
  AWS_REGION    = var.AWS_REGION
  AWS_AMI       = var.AWS_AMI
  az            = var.az
  
  vpc_cidr      = "10.0.0.0/16"
  subnet_cidr   = "10.0.1.0/24"
  
  key           = var.key
  passwd        = var.passwd

  ansible_script_path = "../../modules/scripts/ansible_prod.sh"

  ansible_count      = var.ansible_count
  docker_count       = var.docker_count
  swarm_master_count = var.swarm_master_count
  swarm_worker_count = var.swarm_worker_count
  k8s_count          = var.k8s_count
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
   
  count = var.env == "prod" ? 1 : 0

  name = "${var.env}-Kubernetes-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  count = var.env == "prod" ? 1 : 0

  cluster_name    = "TaskApp-cluster"
  cluster_version = "1.31" 

  vpc_id     = module.vpc[0].vpc_id
  subnet_ids = module.vpc[0].private_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.small"] # 
      capacity_type  = "ON_DEMAND"
    }
  }
}
