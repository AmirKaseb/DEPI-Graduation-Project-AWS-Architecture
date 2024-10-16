# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}
/*
# Create an S3 bucket
resource "aws_s3_bucket" "terraform_backend_2" {
  bucket = "espace-terraform-backend-2"
  tags = {
    Name = "terraform-backend-2"
  }
}
*/
# Create an AWS keypair
# Please ensure that the location of the public key is correct
resource "aws_key_pair" "depi-key-pair" {
  key_name   = "depi-key-pair"
  public_key = file("/home/abdelrahman/.ssh/DEPI.pub")
}

# Create a VPC
resource "aws_vpc" "Depi_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name               = "Depi_vpc"
    Graduation_Project = "True"
    Task               = "Amir Kasseb "
  }
}

# Create Private Subnets 

# Private Subnet 1 
resource "aws_subnet" "private-subnet-1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.Depi_vpc.id
  cidr_block        = "10.0.0.0/24"
  tags = {
    Name = "private-subnet-1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private-subnet-2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.Depi_vpc.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name               = "private-subnet-2"
    Graduation_Project = "True"
    Task               = "Amir Kasseb "
  }
}

# Private Subnet 3
resource "aws_subnet" "private-subnet-3" {
  availability_zone = "us-east-1c"
  vpc_id            = aws_vpc.Depi_vpc.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name               = "private-subnet-3"
    Graduation_Project = "True"
    Task               = "Amir Kasseb "
  }
}

# Create Public Subnets 

# Public Subnet 1 
resource "aws_subnet" "public-subnet-1" {
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.Depi_vpc.id
  cidr_block              = "10.0.3.0/24"
  tags = {
    Name               = "public-subnet-1"
    Graduation_Project = "True"
    Task               = "Amir Kasseb "
  }
}

# Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.Depi_vpc.id
  cidr_block        = "10.0.4.0/24"
  tags = {
    Name               = "public-subnet-2"
    Graduation_Project = "True"
    Task               = "Amir Kasseb "
  }
}

# Public Subnet 3
resource "aws_subnet" "public-subnet-3" {
  availability_zone = "us-east-1c"
  vpc_id            = aws_vpc.Depi_vpc.id
  cidr_block        = "10.0.5.0/24"
  tags = {
    Name               = "pubic-subnet-3"
    Graduation_Project = "True"
    Task               = "Amir Kasseb "
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
  domain = "vpc" # Specify that the Elastic IP is for use in a VPC
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
  vpc_id      = aws_vpc.Depi_vpc.id
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
  ami                    = "ami-005fc0f236362e99f"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.depi-key-pair.id
  subnet_id              = aws_subnet.public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.bastion_host_secuirty_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "bastion"
    # Service = ""
    # Env     = ""
    # Role    = ""
    Team    = "team-1"
    Privacy = "public"
  }
}

# Create the private app security group & private app ec2 instance
resource "aws_security_group" "private_app_secuirty_group" {
  name        = "private_app_secuirty_group"
  description = "This security group is for private app"
  vpc_id      = aws_vpc.Depi_vpc.id

  # Allowing SSH On private app 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.2.0/24"]
  }

  # Allow Jenkins access on port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]
  }

  # Allow Backend access on port 8085
  ingress {
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]
  }

  # Allowing all outbounding traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Jenkins server instance configuration
resource "aws_instance" "jenkins_server_instance" {
  ami                    = "ami-005fc0f236362e99f"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.depi-key-pair.id
  subnet_id              = aws_subnet.private-subnet-3.id
  vpc_security_group_ids = [aws_security_group.private_app_secuirty_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "private-jenkins-server"
    # Service = ""
    # Env     = ""
    # Role    = ""
    Team    = "team-1"
    Privacy = "private"
    Jenkins = "master"
  }
}

# Backend server instance configuration
resource "aws_instance" "depi_backend_server" {
  ami                    = "ami-005fc0f236362e99f"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.depi-key-pair.id
  subnet_id              = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [aws_security_group.private_app_secuirty_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "private-backend-server"
    # Service = ""
    # Env     = ""
    # Role    = ""
    Team    = "team-1"
    Privacy = "private"
    Jenkins = "worker"
  }
}

# Create IAM Role for EC2 instances to interact with CloudWatch
resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach CloudWatch Agent Policy to IAM Role
resource "aws_iam_policy_attachment" "cloudwatch_agent_policy_attachment" {
  name       = "cloudwatch-agent-policy-attachment"
  roles      = [aws_iam_role.ec2_cloudwatch_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach AmazonEC2RoleforSSM Policy to IAM Role (for System Manager access)
resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "ec2-ssm-policy-attachment"
  roles      = [aws_iam_role.ec2_cloudwatch_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

# Security Group for RDS
resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.Depi_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # Allow port 3306 access from private subnet 1 ,2 ,3 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # Allow ssh access from private subnet 1 , 2 , 3
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"] # To any destination
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
  subnet_ids = [aws_subnet.private-subnet-2.id, aws_subnet.private-subnet-3.id]
  tags = {
    Name = "rds-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "depi-rds-instance" {
  identifier             = "depi-rds-instance"
  instance_class         = "db.t3.micro"
  engine                 = "mysql"
  engine_version         = "8.0"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["username"]
  password               = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["password"]
  db_name                = "RdsInstanceDatabase"
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name

  # Enable enhanced monitoring and attach the IAM role
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  # Choose the logs to export
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  tags = {
    Name = "depi-rds-instance"
  }
}

resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds_monitoring_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
