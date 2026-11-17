# -----------------------------------------------------------------------
# Data source: latest Amazon Linux 2023 AMI in ap-south-1
# -----------------------------------------------------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# -----------------------------------------------------------------------
# Data source: public subnet deployed by the network stack
# Identified by its Name tag value as it appears in the deployed HCL above
# -----------------------------------------------------------------------
data "aws_subnet" "webapp_public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["webapp-public-subnet"]
  }
}

# -----------------------------------------------------------------------
# Data source: security group deployed by the network stack
# Identified by its name as it appears in the deployed HCL above
# -----------------------------------------------------------------------
data "aws_security_group" "webapp_sg" {
  name = "webapp-sg"
}

# -----------------------------------------------------------------------
# EC2 instance: webapp-aws
# t3.micro, Amazon Linux 2023, public subnet, Apache on port 8080
# -----------------------------------------------------------------------
resource "aws_instance" "webapp_ec2" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.webapp_public_subnet.id
  associate_public_ip_address = true
  key_name                    = "ec2-key-pair"
  vpc_security_group_ids      = [data.aws_security_group.webapp_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    yum install -y httpd
    sed -i 's/^Listen 80$/Listen 8080/' /etc/httpd/conf/httpd.conf
    echo '<html><body><h1>Hello from AWS Full Stack</h1></body></html>' > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
  EOF

  tags = {
    Name  = "webapp-aws"
    Stack = "compute"
  }
}

# -----------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------
output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.webapp_ec2.public_ip
}

output "ssh_command" {
  description = "Ready-to-use SSH command to connect to the instance"
  value       = "ssh -i ec2-key-pair.pem ec2-user@${aws_instance.webapp_ec2.public_ip}"
}

output "s3_bucket_name" {
  description = "S3 bucket name (deployed by the s3 stack)"
  value       = "gowri-fullstack-assets"
}