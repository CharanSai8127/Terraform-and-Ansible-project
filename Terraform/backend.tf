terraform {
  backend "s3" {
    bucket         = "new-ansibleproject-using-terraform"
    key            = "charan/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-now"
  }
}


