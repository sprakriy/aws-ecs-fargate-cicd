Production-Ready ECS Fargate CD Pipeline
This project demonstrates a fully automated, serverless web application architecture on AWS using Terraform for Infrastructure as Code (IaC) and GitHub Actions for Continuous Deployment.

🚀 Architecture Overview
The infrastructure is built on a "Zero-Maintenance" philosophy using AWS Fargate to remove the need for EC2 instance management.

Compute: AWS ECS Fargate (Serverless Containers)

Networking: Application Load Balancer (ALB) with Public/Private Security Group mapping.

CI/CD: GitHub Actions using OIDC (OpenID Connect) for secure, keyless authentication to AWS.

IaC: Modular Terraform configurations.

🛠️ Key Features
Zero-Secrets Deployment: Utilizes AWS IAM Identity Providers and OIDC to eliminate the need for storing long-lived AWS_ACCESS_KEY_ID in GitHub.

Immutable Infrastructure: Every deployment generates a unique Docker image tag based on the Git Commit SHA, ensuring 100% traceability and easy rollbacks.

Rolling Updates: ECS handles "Blue/Green" style deployments by draining old connections only after new containers pass health checks.

Automated Scaling: (Optional) Integrated with App Auto Scaling to adjust container count based on real-time CPU utilization.
| Component        | Technology                    |   |   |   |
|------------------|-------------------------------|---|---|---|
| Cloud Provider   | AWS (ECS, ECR, ALB, IAM, VPC) |   |   |   |
| IaC              | Terraform                     |   |   |   |
| CI/CD            | GitHub Actions                |   |   |   |
| Containerization | Docker                        |   |   |   |
| Language         | HTML/Nginx                    |   |   |   |
