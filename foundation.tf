# 1. The Provider (Simplified for 2026) already created as pre-requisite
/*
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # In 2026, AWS handles the thumbprint automatically for GitHub.
  # We leave this empty or use a dummy to satisfy Terraform if needed.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] 
}
*/
# 2. The Repository
#resource "aws_ecr_repository" "app_repo" {
#  name         = "my-fargate-app"
#  force_delete = true
#}
# Fetch the existing OIDC provider using its URL

data "aws_iam_openid_connect_provider" "example" {
  url = "https://token.actions.githubusercontent.com" # Replace with your OIDC provider URL (e.g., app.terraform.io, accounts.google.com, or your EKS cluster OIDC issuer URL)
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
          Federated = data.aws_iam_openid_connect_provider.example.arn
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
            /*
             StringLike: {
               "token.actions.githubusercontent.com:sub": "repo:sprakriy/*:*"
              }
              */
              StringLike: {
                "token.actions.githubusercontent.com:sub": [
                    "repo:sprakriy/my-devops-showcase:*",
                    "repo:sprakriy/aws-ecs-fargate-cicd:*"
                ]             
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
resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsDeployPolicy"
  description = "Minimal policy for VPC, ECR, and ECS deployment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # 1. Network Setup (VPC, Subnets, TG, Listeners)
        Effect   = "Allow"
        Action   = [
          "ec2:CreateVpc", "ec2:CreateSubnet", "ec2:CreateTags",
          "ec2:Describe*", "ec2:CreateRouteTable", "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway", "ec2:AuthorizeSecurityGroupIngress",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      {
        # 2. ECR Access (Push and Pull)
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        # 3. ECS Access
        Effect   = "Allow"
        Action   = [
          "ecs:CreateCluster", "ecs:RegisterTaskDefinition",
          "ecs:UpdateService", "ecs:CreateService",
          "iam:PassRole" # Critical for ECS to "take" the execution role
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_attach" {
  role       = aws_iam_role.github_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}
# Output the Role ARN for GitHub Actions
output "role_arn" {
  value = aws_iam_role.github_role.arn
}
