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