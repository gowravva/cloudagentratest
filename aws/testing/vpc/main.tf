# ─────────────────────────────────────────────────────────────
# Data sources
# ─────────────────────────────────────────────────────────────

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# ─────────────────────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────────────────────

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "main-vpc"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Subnets - Public
# ─────────────────────────────────────────────────────────────

resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name  = "public-subnet-az1"
    Tier  = "public"
    Stack = "vpc"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name  = "public-subnet-az2"
    Tier  = "public"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Subnets - Private App
# ─────────────────────────────────────────────────────────────

resource "aws_subnet" "private_app_subnet_az1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name  = "private-app-subnet-az1"
    Tier  = "private-app"
    Stack = "vpc"
  }
}

resource "aws_subnet" "private_app_subnet_az2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name  = "private-app-subnet-az2"
    Tier  = "private-app"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Subnets - Private Data
# ─────────────────────────────────────────────────────────────

resource "aws_subnet" "private_data_subnet_az1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.20.21.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name  = "private-data-subnet-az1"
    Tier  = "private-data"
    Stack = "vpc"
  }
}

resource "aws_subnet" "private_data_subnet_az2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.20.22.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name  = "private-data-subnet-az2"
    Tier  = "private-data"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────────────────────

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name  = "main-igw"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Elastic IPs for NAT Gateways
# ─────────────────────────────────────────────────────────────

resource "aws_eip" "nat_eip_az1" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name  = "nat-eip-az1"
    Stack = "vpc"
  }
}

resource "aws_eip" "nat_eip_az2" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name  = "nat-eip-az2"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# NAT Gateways (one per AZ, in public subnets)
# ─────────────────────────────────────────────────────────────

resource "aws_nat_gateway" "nat_gw_az1" {
  allocation_id = aws_eip.nat_eip_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name  = "nat-gw-az1"
    Stack = "vpc"
  }
}

resource "aws_nat_gateway" "nat_gw_az2" {
  allocation_id = aws_eip.nat_eip_az2.id
  subnet_id     = aws_subnet.public_subnet_az2.id

  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name  = "nat-gw-az2"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Route Tables
# ─────────────────────────────────────────────────────────────

# Public - shared across both public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name  = "public-route-table"
    Tier  = "public"
    Stack = "vpc"
  }
}

# Private App - AZ-1
resource "aws_route_table" "private_app_rt_az1" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az1.id
  }

  tags = {
    Name  = "private-app-route-table-az1"
    Tier  = "private-app"
    Stack = "vpc"
  }
}

# Private App - AZ-2
resource "aws_route_table" "private_app_rt_az2" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az2.id
  }

  tags = {
    Name  = "private-app-route-table-az2"
    Tier  = "private-app"
    Stack = "vpc"
  }
}

# Private Data - AZ-1
resource "aws_route_table" "private_data_rt_az1" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az1.id
  }

  tags = {
    Name  = "private-data-route-table-az1"
    Tier  = "private-data"
    Stack = "vpc"
  }
}

# Private Data - AZ-2
resource "aws_route_table" "private_data_rt_az2" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az2.id
  }

  tags = {
    Name  = "private-data-route-table-az2"
    Tier  = "private-data"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Route Table Associations
# ─────────────────────────────────────────────────────────────

resource "aws_route_table_association" "public_rta_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_app_rta_az1" {
  subnet_id      = aws_subnet.private_app_subnet_az1.id
  route_table_id = aws_route_table.private_app_rt_az1.id
}

resource "aws_route_table_association" "private_app_rta_az2" {
  subnet_id      = aws_subnet.private_app_subnet_az2.id
  route_table_id = aws_route_table.private_app_rt_az2.id
}

resource "aws_route_table_association" "private_data_rta_az1" {
  subnet_id      = aws_subnet.private_data_subnet_az1.id
  route_table_id = aws_route_table.private_data_rt_az1.id
}

resource "aws_route_table_association" "private_data_rta_az2" {
  subnet_id      = aws_subnet.private_data_subnet_az2.id
  route_table_id = aws_route_table.private_data_rt_az2.id
}

# ─────────────────────────────────────────────────────────────
# CloudWatch Log Group - VPC Flow Logs destination
# ─────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "/vpc/flow-logs/main"
  retention_in_days = 30

  tags = {
    Name  = "vpc-flow-logs"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# IAM Role - VPC Flow Logs
# ─────────────────────────────────────────────────────────────

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name  = "vpc-flow-logs-role"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# IAM Inline Policy - allow writing to CloudWatch Logs
# ─────────────────────────────────────────────────────────────

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# ─────────────────────────────────────────────────────────────
# VPC Flow Log
# ─────────────────────────────────────────────────────────────

resource "aws_flow_log" "main_vpc_flow_log" {
  vpc_id          = aws_vpc.main_vpc.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn

  depends_on = [
    aws_iam_role_policy.vpc_flow_logs_policy
  ]

  tags = {
    Name  = "main-vpc-flow-log"
    Stack = "vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the main VPC"
  value       = aws_vpc.main_vpc.cidr_block
}

output "public_subnet_az1_id" {
  description = "ID of the public subnet in AZ-1"
  value       = aws_subnet.public_subnet_az1.id
}

output "public_subnet_az2_id" {
  description = "ID of the public subnet in AZ-2"
  value       = aws_subnet.public_subnet_az2.id
}

output "private_app_subnet_az1_id" {
  description = "ID of the private app subnet in AZ-1"
  value       = aws_subnet.private_app_subnet_az1.id
}

output "private_app_subnet_az2_id" {
  description = "ID of the private app subnet in AZ-2"
  value       = aws_subnet.private_app_subnet_az2.id
}

output "private_data_subnet_az1_id" {
  description = "ID of the private data subnet in AZ-1"
  value       = aws_subnet.private_data_subnet_az1.id
}

output "private_data_subnet_az2_id" {
  description = "ID of the private data subnet in AZ-2"
  value       = aws_subnet.private_data_subnet_az2.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main_igw.id
}

output "nat_gateway_az1_id" {
  description = "ID of the NAT Gateway in AZ-1"
  value       = aws_nat_gateway.nat_gw_az1.id
}

output "nat_gateway_az2_id" {
  description = "ID of the NAT Gateway in AZ-2"
  value       = aws_nat_gateway.nat_gw_az2.id
}

output "public_route_table_id" {
  description = "ID of the shared public route table"
  value       = aws_route_table.public_rt.id
}

output "private_app_route_table_az1_id" {
  description = "ID of the private-app route table for AZ-1"
  value       = aws_route_table.private_app_rt_az1.id
}

output "private_app_route_table_az2_id" {
  description = "ID of the private-app route table for AZ-2"
  value       = aws_route_table.private_app_rt_az2.id
}

output "private_data_route_table_az1_id" {
  description = "ID of the private-data route table for AZ-1"
  value       = aws_route_table.private_data_rt_az1.id
}

output "private_data_route_table_az2_id" {
  description = "ID of the private-data route table for AZ-2"
  value       = aws_route_table.private_data_rt_az2.id
}

output "public_rta_az1_id" {
  description = "Route table association ID - public subnet AZ-1"
  value       = aws_route_table_association.public_rta_az1.id
}

output "public_rta_az2_id" {
  description = "Route table association ID - public subnet AZ-2"
  value       = aws_route_table_association.public_rta_az2.id
}

output "private_app_rta_az1_id" {
  description = "Route table association ID - private-app subnet AZ-1"
  value       = aws_route_table_association.private_app_rta_az1.id
}

output "private_app_rta_az2_id" {
  description = "Route table association ID - private-app subnet AZ-2"
  value       = aws_route_table_association.private_app_rta_az2.id
}

output "private_data_rta_az1_id" {
  description = "Route table association ID - private-data subnet AZ-1"
  value       = aws_route_table_association.private_data_rta_az1.id
}

output "private_data_rta_az2_id" {
  description = "Route table association ID - private-data subnet AZ-2"
  value       = aws_route_table_association.private_data_rta_az2.id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.main_vpc_flow_log.id
}

output "vpc_flow_log_group_arn" {
  description = "ARN of the CloudWatch Log Group receiving VPC Flow Logs"
  value       = aws_cloudwatch_log_group.vpc_flow_log_group.arn
}

output "vpc_flow_logs_role_arn" {
  description = "ARN of the IAM role used by VPC Flow Logs"
  value       = aws_iam_role.vpc_flow_logs_role.arn
}