# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────
resource "aws_vpc" "webapp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "webapp-vpc"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────
resource "aws_internet_gateway" "webapp_igw" {
  vpc_id = aws_vpc.webapp_vpc.id

  tags = {
    Name  = "webapp-igw"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Public Subnet
# ─────────────────────────────────────────────
resource "aws_subnet" "webapp_public_subnet" {
  vpc_id                  = aws_vpc.webapp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "webapp-public-subnet"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Private Subnet
# ─────────────────────────────────────────────
resource "aws_subnet" "webapp_private_subnet" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name  = "webapp-private-subnet"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Public Route Table (default route → IGW)
# ─────────────────────────────────────────────
resource "aws_route_table" "webapp_public_rt" {
  vpc_id = aws_vpc.webapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp_igw.id
  }

  tags = {
    Name  = "webapp-public-rt"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Route Table Association - public subnet
# ─────────────────────────────────────────────
resource "aws_route_table_association" "webapp_public_rt_association" {
  subnet_id      = aws_subnet.webapp_public_subnet.id
  route_table_id = aws_route_table.webapp_public_rt.id
}

# ─────────────────────────────────────────────
# Security Group (shell - rules managed separately)
# ─────────────────────────────────────────────
resource "aws_security_group" "webapp_sg" {
  name        = "webapp-sg"
  description = "Security group for webapp: SSH and HTTP 8080 inbound, all outbound"
  vpc_id      = aws_vpc.webapp_vpc.id

  tags = {
    Name  = "webapp-sg"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Ingress rule - SSH (TCP 22)
# ─────────────────────────────────────────────
resource "aws_vpc_security_group_ingress_rule" "webapp_sg_ingress_ssh" {
  security_group_id = aws_security_group.webapp_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow inbound SSH from anywhere"

  tags = {
    Name  = "webapp-sg-ingress-ssh"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Ingress rule - HTTP (TCP 8080)
# ─────────────────────────────────────────────
resource "aws_vpc_security_group_ingress_rule" "webapp_sg_ingress_http" {
  security_group_id = aws_security_group.webapp_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  description       = "Allow inbound HTTP on port 8080 from anywhere"

  tags = {
    Name  = "webapp-sg-ingress-http"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Egress rule - all traffic
# ─────────────────────────────────────────────
resource "aws_vpc_security_group_egress_rule" "webapp_sg_egress_all" {
  security_group_id = aws_security_group.webapp_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

  tags = {
    Name  = "webapp-sg-egress-all"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Outputs - consumed by the compute stack
# ─────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the webapp VPC"
  value       = aws_vpc.webapp_vpc.id
}

output "public_subnet_id" {
  description = "ID of the webapp public subnet"
  value       = aws_subnet.webapp_public_subnet.id
}

output "private_subnet_id" {
  description = "ID of the webapp private subnet"
  value       = aws_subnet.webapp_private_subnet.id
}

output "internet_gateway_id" {
  description = "ID of the webapp Internet Gateway"
  value       = aws_internet_gateway.webapp_igw.id
}

output "public_route_table_id" {
  description = "ID of the webapp public route table"
  value       = aws_route_table.webapp_public_rt.id
}

output "security_group_id" {
  description = "ID of the webapp security group"
  value       = aws_security_group.webapp_sg.id
}