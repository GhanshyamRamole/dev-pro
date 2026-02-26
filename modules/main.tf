# --- VPC & Networking ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = { Name = "${var.env}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az
  tags                    = { Name = "${var.env}-public-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.env}-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.env}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# --- Security Group ---
resource "aws_security_group" "web_sg" {
  name   = "${var.env}-allow-web-traffic"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = [22, 80, 81, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Node Servers ---

# 1. Standalone Docker (Dev/Prod)
resource "aws_instance" "docker" {
  count                  = var.docker_count
  ami                    = var.AWS_AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public.id
  key_name               = var.key
  user_data              = file("${path.module}/scripts/docker.sh")
  tags                   = { Name = "${var.env}-docker-server" }
}

# 2. Kubernetes Node (Prod)
resource "aws_instance" "cluster" {
  count                  = var.k8s_count
  ami                    = var.AWS_AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public.id
  key_name               = var.key
  user_data              = file("${path.module}/scripts/cluster.sh")
  tags                   = { Name = "${var.env}-kubernetes-server" }
}

# 3. Docker Swarm Master & Workers (Stage)
resource "aws_instance" "swarm_master" {
  count                  = var.swarm_master_count
  ami                    = var.AWS_AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public.id
  key_name               = var.key
  user_data              = file("${path.module}/scripts/docker.sh")
  tags                   = { Name = "${var.env}-swarm-master" }
}

resource "aws_instance" "swarm_worker" {
  count                  = var.swarm_worker_count
  ami                    = var.AWS_AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public.id
  key_name               = var.key
  user_data              = file("${path.module}/scripts/docker.sh")
  tags                   = { Name = "${var.env}-swarm-worker-${count.index}" }
}

# 4. Ansible Control Plane (Common to all)
resource "aws_instance" "ansible" {
  count                  = var.ansible_count
  ami                    = var.AWS_AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public.id
  key_name               = var.key
  user_data = file("${path.root}/${var.ansible_script_path}")

  connection {
    type     = "ssh"
    user     = "ec2-user" 
    password = var.passwd
    host     = self.public_ip
    timeout  = "2m"
  }
  
  provisioner "remote-exec" {
    inline = flatten([
      # Loop through any created Docker standalone nodes
      [for i in aws_instance.docker : "echo '${i.private_ip} docker-server' | sudo tee -a /etc/hosts"],
      
      # Loop through any created Kubernetes nodes
      [for i in aws_instance.cluster : "echo '${i.private_ip} kubernetes-server' | sudo tee -a /etc/hosts"],
      
      # Loop through Swarm Master
      [for i in aws_instance.swarm_master : "echo '${i.private_ip} Master' | sudo tee -a /etc/hosts"],
      
      # Loop through Swarm Workers
      [for i in aws_instance.swarm_worker : "echo '${i.private_ip} worker-node${count.index + 1}' | sudo tee -a /etc/hosts"]
    ])
  }

  tags = { Name = "${var.env}-ansible-server" }
}
