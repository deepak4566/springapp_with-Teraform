terraform {
   backend "s3" {
    bucket         = "deepak-s3-bucket1" # change this
    key            = "deepak/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
 }
 }
