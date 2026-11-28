# ─────────────────────────────────────────────────────────────
# CloudWatch Log Group for VPC Flow Logs
# ─────────────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/vpc/flow-logs/main"
  retention_in_days = 30

  tags = {
    Name  = "main-vpc-flow-logs"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────
# IAM - assume-role policy document
# ─────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "flow_logs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

# ─────────────────────────────────────────────────────────────
# IAM - inline permissions document
# ─────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "flow_logs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

# ─────────────────────────────────────────────────────────────
# IAM Role for VPC Flow Logs delivery
# ─────────────────────────────────────────────────────────────
resource "aws_iam_role" "flow_logs" {
  name               = "vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role.json

  tags = {
    Name  = "vpc-flow-logs-role"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────
# IAM Role Policy (inline) - CWL write permissions
# ─────────────────────────────────────────────────────────────
resource "aws_iam_role_policy" "flow_logs" {
  name   = "vpc-flow-logs-policy"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs_policy.json
}

# ─────────────────────────────────────────────────────────────
# VPC  -  10.20.0.0/16
# ─────────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "main-vpc"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────
# VPC Flow Log  -  ALL traffic → CloudWatch
# ─────────────────────────────────────────────────────────────
resource "aws_flow_log" "main" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn

  tags = {
    Name  = "main-vpc-flow-log"
    Stack = "network"
  }

  depends_on = [aws_iam_role_policy.flow_logs]
}

# ─────────────────────────────────────────────────────────────
# Data source: available AZs (opt-in-not-required only)
# ─────────────────────────────────────────────────────────────
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# ─────────────────────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────────────────────
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "main-igw"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────
# Public subnets
# ─────────────────────────────────────────────────────────────
resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name  = "public-subnet-az1"
    Stack = "network"
    Tier  = "public"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name  = "public-subnet-az2"
    Stack = "network"
    Tier  = "public"
  }
}

# ─────────────────────────────────────────────────────────────
# Private app subnets
# ─────────────────────────────────────────────────────────────
resource "aws_subnet" "private_app_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name  = "private-app-subnet-az1"
    Stack = "network"
    Tier  = "private-app"
  }
}

resource "aws_subnet" "private_app_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name  = "private-app-subnet-az2"
    Stack = "network"
    Tier  = "private-app"
  }
}

# ─────────────────────────────────────────────────────────────
# Private data subnets
# ─────────────────────────────────────────────────────────────
resource "aws_subnet" "private_data_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.21.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name  = "private-data-subnet-az1"
    Stack = "network"
    Tier  = "private-data"
  }
}

resource "aws_subnet" "private_data_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.22.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name  = "private-data-subnet-az2"
    Stack = "network"
    Tier  = "private-data"
  }
}

# ─────────────────────────────────────────────────────────────
# Elastic IPs for NAT Gateways
# EIPs depend on the IGW per AWS ordering requirement
# ─────────────────────────────────────────────────────────────
resource "aws_eip" "nat_az1" {
  domain = "vpc"

  tags = {
    Name  = "nat-eip-az1"
    Stack = "network"
  }

  depends_on = [aws_internet_gateway.main_igw]
}

resource "aws_eip" "nat_az2" {
  domain = "vpc"

  tags = {
    Name  = "nat-eip-az2"
    Stack = "network"
  }

  depends_on = [aws_internet_gateway.main_igw]
}

# ─────────────────────────────────────────────────────────────
# NAT Gateways - one per AZ, placed in public subnets
# ─────────────────────────────────────────────────────────────
resource "aws_nat_gateway" "az1" {
  allocation_id = aws_eip.nat_az1.id
  subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name  = "nat-gw-az1"
    Stack = "network"
  }

  depends_on = [aws_internet_gateway.main_igw]
}

resource "aws_nat_gateway" "az2" {
  allocation_id = aws_eip.nat_az2.id
  subnet_id     = aws_subnet.public_az2.id

  tags = {
    Name  = "nat-gw-az2"
    Stack = "network"
  }

  depends_on = [aws_internet_gateway.main_igw]
}

# ─────────────────────────────────────────────────────────────
# Route Tables
# ─────────────────────────────────────────────────────────────

# Shared public route table - 0.0.0.0/0 → IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name  = "public-rt"
    Stack = "network"
  }
}

# Private app AZ-1 - 0.0.0.0/0 → NAT GW AZ-1
resource "aws_route_table" "private_app_az1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az1.id
  }

  tags = {
    Name  = "private-app-rt-az1"
    Stack = "network"
  }
}

# Private app AZ-2 - 0.0.0.0/0 → NAT GW AZ-2
resource "aws_route_table" "private_app_az2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az2.id
  }

  tags = {
    Name  = "private-app-rt-az2"
    Stack = "network"
  }
}

# Private data AZ-1 - 0.0.0.0/0 → NAT GW AZ-1
resource "aws_route_table" "private_data_az1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az1.id
  }

  tags = {
    Name  = "private-data-rt-az1"
    Stack = "network"
  }
}

# Private data AZ-2 - 0.0.0.0/0 → NAT GW AZ-2
resource "aws_route_table" "private_data_az2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az2.id
  }

  tags = {
    Name  = "private-data-rt-az2"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────
# Route Table Associations
# ─────────────────────────────────────────────────────────────

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app_az1_assoc" {
  subnet_id      = aws_subnet.private_app_az1.id
  route_table_id = aws_route_table.private_app_az1.id
}

resource "aws_route_table_association" "private_app_az2_assoc" {
  subnet_id      = aws_subnet.private_app_az2.id
  route_table_id = aws_route_table.private_app_az2.id
}

resource "aws_route_table_association" "private_data_az1_assoc" {
  subnet_id      = aws_subnet.private_data_az1.id
  route_table_id = aws_route_table.private_data_az1.id
}

resource "aws_route_table_association" "private_data_az2_assoc" {
  subnet_id      = aws_subnet.private_data_az2.id
  route_table_id = aws_route_table.private_data_az2.id
}