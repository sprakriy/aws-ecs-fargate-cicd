# This tells AWS to trust GitHub's token server
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  
  # AWS uses this thumbprint to verify the certificate of GitHub's server
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] 
}
# 1. Define who can assume this role (The Trust Policy)
data "aws_iam_policy_document" "github_allow" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # REPLACE 'your-username/your-repo' with your actual GitHub path
      values   = ["repo:your-username/your-repo:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# 2. Create the Role
resource "aws_iam_role" "github_role" {
  name               = "github-actions-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_allow.json
}