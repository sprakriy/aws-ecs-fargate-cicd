terraform {
  backend "s3" {
    bucket       = "my-fargate-tfstate-319310747432"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    # dynamodb_table = "terraform-locks" <--- Remove or comment this out
    use_lockfile = true                # <--- Add this instead
    encrypt      = true
  }
}