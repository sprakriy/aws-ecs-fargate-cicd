resource "aws_s3_bucket" "terraform_state" {
  bucket        = "sprakriya-tf-state-storage" # Must be globally unique

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # In 2026, AWS handles the thumbprint automatically for GitHub.
  # We leave this empty or use a dummy to satisfy Terraform if needed.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  
  lifecycle {
    prevent_destroy = true
  }
 
}
