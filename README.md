# AWS Developer Environment
![image](https://github.com/AlonsoBTech/AWS-Project-Developer-Environment/assets/160416175/5b246a3a-34c5-476b-9bc2-531fdefa196d)

## 📋 <a name="table">Table of Contents</a>

1. 🤖 [Introduction](#introduction)
2. ⚙️ [Prerequisites](#prerequisites)
3. 🔋 [What Is Being Created](#what-is-being-created)
4. 🤸 [Quick Guide](#quick-guide)
5. 🔗 [Links](#links)
7. 🚀 [More](#more)


## <a name="introduction">🤖 Introduction</a>

Creating an environment in AWS for developers. This environment will have an EC2 deployed that has docker installed
and ready to use for spinning up containers when needed.

## <a name="prerequisites">⚙️ Prerequisites</a>

Make sure you have the following:

- AWS Account
- AWS IAM User
- Terraform Installed
- IDE of choice to write Terraform code

## <a name="what-is-being-created">🔋 What Is Being Created</a>

What we will be creating:

- VPC
- VPC Subnet
- VPC Internet Gateway
- VPC Route Table
- VPC Route Table Route
- VPC Route Table Association
- EC2

## <a name="quick-guide">🤸 Quick Guide</a>

**First create your git repository (name it whatever you like) then clone the git repository**

```bash
git clone https://github.com/AlonsoBTech/AWS-Project-Developer-Environment.git
cd AWS-Project-Developer-Environment
```

**Create your Terraform providers.tf file**

</details>

<details>
<summary><code>providers.tf</code></summary>

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }
}

provider "aws" {
  region  = "ca-central-1"
}
```
</details>

**Create your Terraform main.tf file**

</details>

<details>
<summary><code>main.tf</code></summary>

```bash
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
  public_key = file("PATH-TO-YOUR-SSH-KEY")
}

### Creating EC2 Instance
resource "aws_instance" "dev1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
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
```
</details>

**Create your Terraform datasources.tf file**

</details>

<details>
<summary><code>datasources.tf</code></summary>
  
```bash
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "http" "my_public_ip" {
    url = "https://ifconfig.co/json"
    request_headers = {
        Accept = "application/json"
    }
}
```
</details>

**Create your Terraform local.tf file**

</details>

<details>
<summary><code>local.tf</code></summary>

```bash
locals {
    my_ip = jsondecode(data.http.my_public_ip.body)
}
```
</details>

**Create your EC2 userdata.sh file**

</details>

<details>
<summary><code>userdata.sh</code></summary>

```bash
#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
</details>

**Create your .gitignore file**

</details>

<details>
<summary><code>.gitignore</code></summary>

```bash
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
docker ready ubuntu.txt
```
</details>

**Add your files to the git repository**

```bash
git add .
```

**Commit the files now**

```bash
git commit -M "Terraform Code"
```

**Push your code to git repository**

```bash
git push origin main
```

