terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_key_pair" "instance-key" {
  key_name   = "new-key"
  public_key = file("/home/ubuntu/.ssh/id_ed25519.pub")
}

resource "aws_vpc" "vpc_new" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "subnet-v1" {
  vpc_id            = aws_vpc.vpc_new.id
  cidr_block        = var.vpc_subnet1_block
  availability_zone = var.avail-zone-1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet-v2" {
  vpc_id            = aws_vpc.vpc_new.id
  cidr_block        = var.vpc_subnet2_block
  availability_zone = var.avail-zone-2
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_new.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc_new.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "associate-rt" {
  subnet_id      = aws_subnet.subnet-v1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "associate-rt1" {
  subnet_id      = aws_subnet.subnet-v2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg-vpc" {
  name_prefix = "Web-sg"
  vpc_id      = aws_vpc.vpc_new.id

  ingress {
    description = "HTTP for vpc"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH for the vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound rule for the vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "project-terraform-ansible-2025"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_instance" "instance-1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.instance-key.key_name
  subnet_id              = aws_subnet.subnet-v1.id
  vpc_security_group_ids = [aws_security_group.sg-vpc.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/ubuntu/.ssh/id_ed25519")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "local-log.txt"
    destination = "/home/ubuntu/logs/instance-log.txt"
  }

}

resource "aws_instance" "instance-2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.instance-key.key_name
  subnet_id              = aws_subnet.subnet-v2.id
  vpc_security_group_ids = [aws_security_group.sg-vpc.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/ubuntu/.ssh/id_ed25519")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "local-log.txt"
    destination = "/home/ubuntu/logs/instance-log-1.txt"
  }

}


resource "aws_lb" "lb" {
  name               = "new-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-vpc.id]
  subnets            = [aws_subnet.subnet-v1.id, aws_subnet.subnet-v2.id]

  tags = {
    Name = "load-balancer"
  }
}

resource "aws_lb_target_group" "target" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_new.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "tg-lb-attach-1" {
  target_group_arn = aws_lb_target_group.target.arn
  target_id        = aws_instance.instance-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg-lb-attach-2" {
  target_group_arn = aws_lb_target_group.target.arn
  target_id        = aws_instance.instance-2.id
  port             = 80
}


resource "aws_lb_listener" "listerner" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target.arn
    type             = "forward"
  }
}
