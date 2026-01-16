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
  name = "aws-fargate-deployer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        /*
        Condition = {
          StringEquals = {
            # This is the EXACT string your debug output gave us
            "token.actions.githubusercontent.com:sub": "repo:sprakriy/aws-ecs-fargate-cicd:ref:refs/heads/main",
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      */
          Condition: {
            StringEquals: {
              "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
            },
             StringLike: {
               "token.actions.githubusercontent.com:sub": "repo:sprakriy/*:*"
              }
            }
  
      }
    ]
  })
  tags = {
    ForcedUpdate = "v2"
  }
}
/*
# 4. Permissions
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.github_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
*/
# 1. Permission to manage ECS Tasks and Services
resource "aws_iam_role_policy_attachment" "ecs_full_access" {
  role       = aws_iam_role.github_role.name
  #policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 2. Permission to pass roles to ECS (Crucial!)
# ECS needs to "become" the Task Execution Role you created
resource "aws_iam_role_policy" "iam_pass_role" {
  name = "allow-iam-pass-role"
  role = aws_iam_role.github_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*" # In a real job, you'd limit this to your Task Execution Role ARN
      }
    ]
  })
}
# Output the Role ARN for GitHub Actions
output "role_arn" {
  value = aws_iam_role.github_role.arn
}