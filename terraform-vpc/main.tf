# AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Step 4: VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Dev-VPC"
  }
}

# Step 5: Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

# Step 6: Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id
}

# Step 7: Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Step 8: Associate Route Table to Subnet
resource "aws_route_table_association" "rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Step 9: Security Group (allow SSH + HTTP)
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.dev_vpc.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Step 10: Two EC2 Instances
resource "aws_instance" "ec2" {
  count                  = 2
  ami                    = "ami-0c02fb55956c7d316"  # Amazon Linux 2 (us-east-1)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = "mpxupd"
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "Dev-EC2-${count.index + 1}"
  }
}