# Import the existing S3 Bucket (The State Storage)
import {
  to = aws_s3_bucket.terraform_state
  id = "sprakriya-tf-state-storage" # Replace with your exact bucket name
}

# Import the existing OIDC Provider (The GitHub Handshake)
import {
  to = aws_iam_openid_connect_provider.github
  id = "arn:aws:iam::319310747432:oidc-provider/token.actions.githubusercontent.com"
}

# import the existing versioning 
import {
  to = aws_s3_bucket_versioning.enabled
  id = "sprakriya-tf-state-storage"
}
