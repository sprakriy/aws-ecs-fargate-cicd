
terraform {
  required_version = ">= 1.10.5" # This covers 1.10.x versions  
  backend "s3" {
    bucket       = "sprakriya-tf-state-storage"
    key          = "fargate-project/terraform.tfstate"
    region       = "us-east-1"
    # dynamodb_table = "terraform-state-locking" #<--- Remove or comment this out
    use_lockfile = true
}
}

