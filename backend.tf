terraform {
  backend "s3" {
    bucket         = "devops-bucket"
    key            = "devops-assignment/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

