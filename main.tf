# 1. Provider For Region US-EAST-1
provider "aws" {
  region = "us-east-1"
  access_key = "test"
  secret_key = "test"
  s3_use_path_style = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  
  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"

  }

}

# 2. Creating VPC For US-EAST-1 (dev_vpc)

resource "aws_vpc" "dev_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev_vpc"
  }
}

# 3. Creating Internet Gateway For US-EAST-1 

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev_vpc.id

}

# 4. Create Custom Route Table For US-EAST-1

resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Dev"
  }
}


# 5. Creating a Public Subnet For US-EAST-1
resource "aws_subnet" "public_subnet-1" {
  vpc_id = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}



# 6. Associate subnet with Route Table 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.dev-route-table.id
}


# 7. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_web"
  }
}

# 8. Create a network interface with an ip in the subnet that was created perviously

resource "aws_network_interface" "web-server-nic-1" {
  subnet_id       = aws_subnet.public_subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
# 9. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic-1.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}


# 10. Instance Creation in US-EAST-1
resource "aws_instance" "instance-1" {
  ami           = "ami-0d57c0143330e1fa7"
  instance_type = "t2.micro"

  tags = {
    Name = "Hello From US-EAST-1 Instance"
  }
}

##### Terraform File For Second Region Instance #######

# 1. Provider For Region US-WEST-2

provider "aws" {
  alias = "us-west-2"
  region = "us-west-2"
  access_key = "test"
  secret_key = "test"
  s3_use_path_style = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"

  }

}

# 2. Creating VPC For US-WEST-2
resource "aws_vpc" "qa_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "qa_vpc"
  }
}

# 3. Create Internet Gateway

resource "aws_internet_gateway" "gw-2" {
  vpc_id = aws_vpc.qa_vpc.id

}
# 4. Create Custom Route Table For US-WEST-2

resource "aws_route_table" "qa-route-table" {
  vpc_id = aws_vpc.qa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-2.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw-2.id
  }

  tags = {
    Name = "Qa"
  }
}


# 5. Creating a Public Subnet For US-WEST-2
resource "aws_subnet" "public_subnet-2" {
  vpc_id = aws_vpc.qa_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

# 6. Associate subnet with Route Table 
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.qa-route-table.id
}
# 7. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web-2" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.qa_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_web-2"
  }
}

# 8. Create a network interface with an ip in the subnet that was created perviously

resource "aws_network_interface" "web-server-nic-2" {
  subnet_id       = aws_subnet.public_subnet-2.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web-2.id]

}
# 9. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic-2.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw-2]
}

# 10. Create the instance in US-WEST-2
resource "aws_instance" "instance-2" {
  ami           = "ami-0d57c0143330e1fa7"
  instance_type = "t2.micro"

  tags = {
    Name = "Hello From US-WEST-2 Instance"
  }

  provider = aws.us-west-2
}
