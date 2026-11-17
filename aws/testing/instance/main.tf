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
    name   = "state"
    values = ["available"]
  }
}

data "aws_subnet" "public" {
  id = "subnet-00260868f0fd32bcf"
}

data "aws_security_group" "webapp_sg" {
  id = "sg-073152a7f6ed0e3fb"
}

