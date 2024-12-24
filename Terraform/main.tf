provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "Terra" {
  instance_type = var.instance_type
  ami           = var.ami_id
  key_name      = var.key
  security_groups = [data.aws_security_group.existing_sg.name]
  tags = {
        name = "new-instance"
}
}

resource "aws_s3_bucket" "ansible-terra" {
  bucket = "new-ansibleproject-using-terraform"
}

data "aws_security_group" "existing_sg" {
  # You can either use the name or ID to find the security group
  name = "default" # Replace "default" with your actual security group name
}

resource "aws_dynamodb_table" "terraform_lock_new" {
  name         = "terraform-lock-now"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
