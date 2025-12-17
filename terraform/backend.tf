terraform {
  backend "s3" {
    bucket  = "awsworkflow-tfstate-sametcatakli"
    key     = "ec2/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

