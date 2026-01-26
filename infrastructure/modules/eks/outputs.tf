output "cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "node_group_arn" {
  description = "EKS Node Group ARN"
  value       = aws_eks_node_group.main.arn
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "cluster_security_group_id" {
  description = "EKS Cluster security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}
