### Creating VPC
resource "aws_vpc" "project1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Project1_VPC"
  }
}

### Creating Public Subnet
resource "aws_subnet" "Project1_Public_Subnet_1" {
  vpc_id                  = aws_vpc.project1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ca-central-1a"

  tags = {
    Name = "Project1_Public"
  }
}

### Creating Internet Gateway
resource "aws_internet_gateway" "Project1_IGW" {
  vpc_id = aws_vpc.project1.id

  tags = {
    Name = "Project1_IGW"
  }
}

### Creating Route Table
resource "aws_route_table" "Project_Public_RT" {
  vpc_id = aws_vpc.project1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Project1_IGW.id
  }

  tags = {
    Name = "Project1_PublicRT"
  }
}

### Creating Route Table Association
resource "aws_route_table_association" "Project1_pub_asso1" {
  subnet_id      = aws_subnet.Project1_Public_Subnet_1.id
  route_table_id = aws_route_table.Project_Public_RT.id
}

### Creating Security Group
resource "aws_security_group" "Project1_DevApp_Sg" {
  name        = "Project1_DevApp_Sg"
  description = "Allow SSH, HTTP, HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.project1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip.ip}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dev-SG"
  }
}

### Creating EC2 SSH Key
resource "aws_key_pair" "project1_key" {
  key_name   = "pj1key"
  public_key = file("~/.ssh/pj1key.pub")
}

### Creating EC2 Instance
resource "aws_instance" "dev1" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  key_name               = aws_key_pair.project1_key.id
  vpc_security_group_ids = [aws_security_group.Project1_DevApp_Sg.id]
  subnet_id              = aws_subnet.Project1_Public_Subnet_1.id
  user_data              = file("userdata.sh")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev1_ec2"
  }
}
