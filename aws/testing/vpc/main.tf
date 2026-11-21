resource "aws_vpc" "test_public_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name  = "test-public-vpc"
    Stack = "vpc"
  }
}

resource "aws_subnet" "test_public_subnet_1a" {
  vpc_id                  = aws_vpc.test_public_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "test-public-subnet-1a"
    Stack = "vpc"
  }
}

resource "aws_internet_gateway" "test_public_igw" {
  vpc_id = aws_vpc.test_public_vpc.id

  tags = {
    Name  = "test-public-igw"
    Stack = "vpc"
  }
}

resource "aws_route_table" "test_public_rt" {
  vpc_id = aws_vpc.test_public_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_public_igw.id
  }

  tags = {
    Name  = "test-public-rt"
    Stack = "vpc"
  }
}

resource "aws_route_table_association" "test_public_rt_assoc" {
  subnet_id      = aws_subnet.test_public_subnet_1a.id
  route_table_id = aws_route_table.test_public_rt.id
}