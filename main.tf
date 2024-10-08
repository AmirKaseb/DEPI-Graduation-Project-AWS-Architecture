# Terraform Configuration & AWS Provider Configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

#   backend "s3" {
#     bucket = "espace-terraform-backend-2"
#     key    = "Terraform-Backend/terraform.tfstate"
#     region = "us-eas-1"
#   }
}

provider "aws" {
  region = "us-east-1"
}

# # Create an S3 bucket
# resource "aws_s3_bucket" "terraform_backend_2" {
#   bucket = "espace-terraform-backend-2"
#   tags = {
#     Name = "terraform-backend-2"
#   }
# }

# Create an AWS keypair
resource "aws_key_pair" "amir-public-key" {
  key_name   = "amir-public-key"
  public_key = file("C:/Users/moham/.ssh/id_rsa.pub")
}

# Create a VPC
resource "aws_vpc" "Depi_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Depi_vpc"
    Graduation_Project = "True"  
    Task = "Amir Kasseb "
  }
}
# Create Private Subnets 

# Private Subnet 1 
resource "aws_subnet" "private-subnet-1" {
  availability_zone = "us-east-1a"
  vpc_id     = aws_vpc.Depi_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "private-subnet-1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private-subnet-2" {
  availability_zone = "us-east-1b"
  vpc_id     = aws_vpc.Depi_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "private-subnet-2"
    Graduation_Project = "True"  
    Task = "Amir Kasseb "
  }
}

# Private Subnet 3
resource "aws_subnet" "private-subnet-3" {
  availability_zone = "us-east-1c"
  vpc_id     = aws_vpc.Depi_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "private-subnet-3"
    Graduation_Project = "True"  
    Task = "Amir Kasseb "
  }
}
# Create Public Subnets 

# Public Subnet 1 
resource "aws_subnet" "public-subnet-1" {
  map_public_ip_on_launch = true 
  availability_zone = "us-east-1a"
  vpc_id     = aws_vpc.Depi_vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "public-subnet-1"
    Graduation_Project = "True"  
    Task = "Amir Kasseb "
  }
}

# Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  availability_zone = "us-east-1b"
  vpc_id     = aws_vpc.Depi_vpc.id
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "public-subnet-2"
    Graduation_Project = "True"  
    Task = "Amir Kasseb "
  }
}

# Public Subnet 3
resource "aws_subnet" "public-subnet-3" {
  availability_zone = "us-east-1c"
  vpc_id     = aws_vpc.Depi_vpc.id
  cidr_block = "10.0.5.0/24"
  tags = {
    Name = "pubic-subnet-3"
    Graduation_Project = "True"  
    Task = "Amir Kasseb "
  }
}

# Create Internet Gateway 

resource "aws_internet_gateway" "depi_internet_gateway" {
  vpc_id = aws_vpc.Depi_vpc.id

  tags = {
    Name = "depi_internet_gateway"
  }
}

# Create  route table  &  associate it to the public subnets 

resource "aws_route_table" "internet-gateaway-routetable" {
  vpc_id = aws_vpc.Depi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.depi_internet_gateway.id
  }


  tags = {
    Name = "internet-gateaway-routetable"
  }
}

# Associate it to the three public subnets 

# Associate to public subnet 1 
resource "aws_route_table_association" "public-association-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.internet-gateaway-routetable.id
}

# Associate to public subnet 2
resource "aws_route_table_association" "public-association-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.internet-gateaway-routetable.id
}

# Associate to public subnet 3
resource "aws_route_table_association" "public-association-3" {
  subnet_id      = aws_subnet.public-subnet-3.id
  route_table_id = aws_route_table.internet-gateaway-routetable.id
}

# Create Elastic ip for the nat-gateaway

resource "aws_eip" "depi_nat_elasticip" {
  domain = "vpc"   # Specify that the Elastic IP is for use in a VPC
}


# Create Nat-Gateway & associate it to the private subnets 

resource "aws_nat_gateway" "depi-nat-gateway" {
  allocation_id = aws_eip.depi_nat_elasticip.id
  subnet_id     = aws_subnet.public-subnet-2.id

  tags = {
    Name = "depi-nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.depi_internet_gateway]
}

# Create route table for private subnets 

resource "aws_route_table" "nat-gateaway-routetable" {
  vpc_id = aws_vpc.Depi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.depi-nat-gateway.id
  }


  tags = {
    Name = "nat-gateaway-routetable"
  }
}

# Associate it to the three private subnets 

# Associate to private subnet 1 
resource "aws_route_table_association" "private-association-1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.nat-gateaway-routetable.id
}

# Associate to private subnet 2
resource "aws_route_table_association" "private-association-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.nat-gateaway-routetable.id
}

# Associate to private subnet 3
resource "aws_route_table_association" "private-association-3" {
  subnet_id      = aws_subnet.private-subnet-3.id
  route_table_id = aws_route_table.nat-gateaway-routetable.id
}

# Create the bastion host security group & bastion host ec2 instance

resource "aws_security_group" "bastion_host_secuirty_group" {
  name        = "bastion_host_secuirty_group"
  description = "This security group is for bastion host"
  vpc_id = aws_vpc.Depi_vpc.id 
# Allowing SSH On bastion host 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


# Allowing all outbounding traffic

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion host ec2 instance configuration

resource "aws_instance" "depi-frontend-server" {
  ami           = "ami-005fc0f236362e99f"
  instance_type = "t2.micro"
  key_name      =  aws_key_pair.amir-public-key.id
  subnet_id = aws_subnet.public-subnet-1.id
  vpc_security_group_ids  = [aws_security_group.private_app_secuirty_group.id]

  tags = {
    Name = "depi-frontend-server"
  }
}
# Create the private app security group & private app ec2 instance

resource "aws_security_group" "private_app_secuirty_group" {
  name        = "private_app_secuirty_group"
  description = "This security group is for private app"
  vpc_id = aws_vpc.Depi_vpc.id 

# Allowing SSH On private app 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


# Allowing all outbounding traffic

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# jenkins server  instance configuration

resource "aws_instance" "jenkins_server_instance" {
  ami           = "ami-005fc0f236362e99f"
  instance_type = "t2.micro"
  key_name      =  aws_key_pair.amir-public-key.id
  subnet_id = aws_subnet.public-subnet-3.id
  vpc_security_group_ids  = [aws_security_group.private_app_secuirty_group.id]

  tags = {
    Name = "jenkins_server_instance"
  }
}
# prometheus server  instance configuration

resource "aws_instance" "depi_backend_server" {
  ami           = "ami-005fc0f236362e99f"
  instance_type = "t2.micro"
  key_name      =  aws_key_pair.amir-public-key.id
  subnet_id = aws_subnet.private-subnet-1.id
  vpc_security_group_ids  = [aws_security_group.private_app_secuirty_group.id]

  tags = {
    Name = "depi_backend_server"
  }
}
# Security Group for RDS

resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id = aws_vpc.Depi_vpc.id 

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]  # Allow port 3306 access from private subnet 1 ,2 ,3 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]   # Allow ssh access from private subnet 1 , 2 , 3
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]  # To any destination
  }

  tags = {
    Name = "rds-security-group"
  }

}

# Create Secret & secret versions for Database credientials 

data "aws_secretsmanager_secret" "rds_secret" {
  name = "RDS-Instance-SecretKey-v1"
}

data "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}


# Create DB Subnet Group
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private-subnet-2.id,aws_subnet.private-subnet-3.id]
  tags = {
    Name = "rds-subnet-group"
  }

}

# RDS Instance
resource "aws_db_instance" "depi-rds-instance" {
  identifier              = "depi-rds-instance"
  instance_class          = "db.t3.micro"
  engine                  = "mysql"
  engine_version          = "8.0"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["username"]
  password                = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["password"]
  db_name                 = "RdsInstanceDatabase"
  vpc_security_group_ids  = [aws_security_group.rds_security_group.id]
  skip_final_snapshot     = true
  db_subnet_group_name  = aws_db_subnet_group.rds-subnet-group.name
  
    tags = {
    Name = "depi-rds-instance"
  }
}


# # Outputs
# output "bastion_host_public_ip" {
#   value = aws_instance.depi-frontend-server.public_ip
#   description = "Public IP address of the bastion host instance"
# }

# # Private IP for the private instance
# output "private_instance_private_ip" {
#   value       = aws_instance.jenkins_server_instance.private_ip
#   description = "Private IP of the private EC2 instance"
# }

output "rds_instance_endpoint" {
  value = aws_db_instance.depi-rds-instance.endpoint
  description = "Endpoint of the RDS instance"
}

# output "s3_bucket_name" {
#   value = aws_s3_bucket.terraform_backend.bucket
#   description = "Name of the S3 bucket used for Terraform state"
# }
