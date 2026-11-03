# ── TLS key material ────────────────────────────────────────────────────────
resource "tls_private_key" "agentra_web_server_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ── AWS key pair ─────────────────────────────────────────────────────────────
resource "aws_key_pair" "agentra_web_server_key" {
  key_name   = "agentra-web-server-key"
  public_key = tls_private_key.agentra_web_server_tls_key.public_key_openssh

  tags = {
    Name  = "agentra-web-server-key"
    Stack = "compute"
  }
}

# ── Write private key to disk for download ───────────────────────────────────
resource "local_sensitive_file" "agentra_web_server_pem" {
  content         = tls_private_key.agentra_web_server_tls_key.private_key_pem
  filename        = "${path.module}/agentra-web-server-key.pem"
  file_permission = "0600"
}

# ── AMI lookup (latest Amazon Linux 2023) ────────────────────────────────────
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── Networking data sources (from the networking stack) ───────────────────────
data "aws_subnet" "agentra_web_server_public" {
  filter {
    name   = "tag:Name"
    values = ["agentra-web-server-public-subnet"]
  }
}

data "aws_security_group" "agentra_web_server_sg" {
  filter {
    name   = "tag:Name"
    values = ["agentra-web-server-sg"]
  }
}

# ── EC2 instance ─────────────────────────────────────────────────────────────
resource "aws_instance" "agentra_web_server" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.agentra_web_server_public.id
  vpc_security_group_ids      = [data.aws_security_group.agentra_web_server_sg.id]
  key_name                    = aws_key_pair.agentra_web_server_key.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name  = "agentra-web-server"
    Stack = "compute"
  }
}