
# Data source to get the default VPC
data "aws_vpc" "default-vpc" {
  default = true
}

# Data source to get the default subnet IDs. Filter: The filter name = "vpc-id" and values = [data.aws_vpc.default.id] ensures that only subnets belonging to the default VPC are retrieved.
data "aws_subnets" "default-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}

resource "aws_security_group" "jenkins-maven_sg" {
  vpc_id = data.aws_vpc.default-vpc.id

  ingress {
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
}

resource "aws_security_group" "sonarqube_sg" {
  vpc_id = data.aws_vpc.default-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
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


resource "aws_security_group" "nexus_sg" {
  vpc_id = data.aws_vpc.default-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
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


resource "aws_instance" "jenkins-maven" {
  ami                         = "ami-0dc2d3e4c0f9ebd18" # Amazon Linux 2 AMI ID
  instance_type               = "t2.micro"
  key_name                    = var.my-key-name
  security_groups             = [aws_security_group.jenkins-maven_sg.id]
  user_data                   = file("./tools/jenkins-maven-install.sh")
  subnet_id                   = element(data.aws_subnets.default-subnets.ids, 0)
  associate_public_ip_address = true

  tags = {
    Name = "jenkins-maven"
  }
}

resource "aws_instance" "sonarqube" {
  ami                         = "ami-032346ab877c418af" # Ubuntu 20.04 LTS AMI ID
  instance_type               = "r5.xlarge"
  key_name                    = var.my-key-name
  security_groups             = [aws_security_group.sonarqube_sg.id]
  user_data                   = file("./tools/sonarqube-install.sh")
  subnet_id                   = element(data.aws_subnets.default-subnets.ids, 0)
  associate_public_ip_address = true

  tags = {
    Name = "SonarQube"
  }
}


resource "aws_instance" "nexus" {
  ami                         = "ami-0dc2d3e4c0f9ebd18" # Amazon Linux 2 AMI ID
  instance_type               = "t2.medium"
  key_name                    = var.my-key-name
  security_groups             = [aws_security_group.nexus_sg.id]
  user_data                   = file("./tools/nexus-install.sh")
  subnet_id                   = element(data.aws_subnets.default-subnets.ids, 0)
  associate_public_ip_address = true

  tags = {
    Name = "Nexus"
  }
}