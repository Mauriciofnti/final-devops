provider "aws" {
  region = "us-east-1"
  # As credenciais do Learner Lab devem estar configuradas no seu AWS CLI
}

# Criando um Grupo de Segurança para o Cluster
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "Permite trafego SSH, HTTP e K3s"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # API do Kubernetes
  }

  # Regra para permitir que as máquinas conversem entre si livremente
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Pegando a AMI mais recente do Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Instância Control Plane (Master)
resource "aws_instance" "control_plane" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium" # Recomendado para o master
  key_name      = "vockey"    # Chave padrão do Learner Lab
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "K8s-ControlPlane"
    Role = "Master"
  }
}

# Instâncias Worker Nodes (3 nós)
resource "aws_instance" "worker_nodes" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" 
  key_name      = "vockey"   
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "K8s-Worker-${count.index + 1}"
    Role = "Worker"
  }
}

# Exibir os IPs no terminal após criar
output "control_plane_ip" {
  value = aws_instance.control_plane.public_ip
}

output "worker_nodes_ips" {
  value = aws_instance.worker_nodes[*].public_ip
}