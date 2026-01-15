# 1. The Provider (Simplified for 2026)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # In 2026, AWS handles the thumbprint automatically for GitHub.
  # We leave this empty or use a dummy to satisfy Terraform if needed.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] 
}

# 2. The Repository
resource "aws_ecr_repository" "app_repo" {
  name         = "my-fargate-app"
  force_delete = true
}

# 3. The "Job-Ready" Role
resource "aws_iam_role" "github_role" {
  name = "aws-fargate-deployer-role" # Renamed for clarity

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            # USE THE WILDCARD (*) - This is the "Circle Breaker"
            "token.actions.githubusercontent.com:sub": "repo:sprakriy/aws-ecs-fargate-cicd:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# 4. Permissions
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.github_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

output "role_arn" {
  value = aws_iam_role.github_role.arn
}