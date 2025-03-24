variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "server_port" {
  description = "Webserver’s HTTP port"
  type        = number
}

variable "alb_security_group_name" {
  description = "The name of the ALB’s security group"
  type        = string
}

variable "alb_name" {
  description = "The name of the ALB"
  type        = string
}