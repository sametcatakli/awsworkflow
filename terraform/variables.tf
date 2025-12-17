variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "awsworkflow"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "CIDR block allowed for SSH access (port 22). WARNING: Default 0.0.0.0/0 allows access from anywhere - restrict this in production!"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Name of the AWS key pair for SSH access (optional)"
  type        = string
  default     = null
}

