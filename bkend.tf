terraform {
  required_version = ">= 1.10.5" # This covers 1.10.x versions  
  backend "s3" {
    bucket       = "my-fargate-tfstate-319310747432"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    dynamodb_table = "terraform-locks" #<--- Remove or comment this out
}
}