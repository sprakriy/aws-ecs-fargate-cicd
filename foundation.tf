# 1. The Trust Relationship (OIDC)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # In 2026, AWS often handles the thumbprint automatically, 
  # but this standard one ensures it works everywhere.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] 
}

# 2. The Repository (Storage)
resource "aws_ecr_repository" "app_repo" {
  name                 = "my-fargate-app"
  force_delete         = true # Helpful for debugging/cleanup
}

# 3. The Role GitHub will use
resource "aws_iam_role" "github_role" {
  name = "github-actions-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:sprakriy/aws-ecs-fargate-cicd:*"
          }
        }
      }
    ]
  })
}

# 4. Give the Role permission to push to ECR
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.github_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# 5. Output the ARN (You need this for GitHub Secrets)
output "github_role_arn" {
  value = aws_iam_role.github_role.arn
}