variable "prefix" {
  description = "Prefix to be used for resource names"
  type        = string
  default     = "ecommerce"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string
}

variable "scale_out_policy_arn" {
  description = "ARN of the scaling policy to execute when scaling out"
  type        = string
}

variable "scale_in_policy_arn" {
  description = "ARN of the scaling policy to execute when scaling in"
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "ARN suffix of the load balancer to monitor"
  type        = string
  default     = ""
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for the alarm"
  type        = number
  default     = 2
}

variable "period" {
  description = "Duration in seconds over which the metric is evaluated"
  type        = number
  default     = 300  # 5 minutes
}

variable "high_cpu_threshold" {
  description = "Threshold for high CPU utilization alarm"
  type        = number
  default     = 70
}

variable "low_cpu_threshold" {
  description = "Threshold for low CPU utilization alarm"
  type        = number
  default     = 30
}

variable "high_network_threshold" {
  description = "Threshold for high network traffic alarm (in bytes)"
  type        = number
  default     = 5000000  # 5 MB
}

variable "high_request_count_threshold" {
  description = "Threshold for high request count alarm"
  type        = number
  default     = 1000
}

variable "high_response_time_threshold" {
  description = "Threshold for high response time alarm (in seconds)"
  type        = number
  default     = 1
}

variable "enable_network_alarms" {
  description = "Whether to enable network traffic alarms"
  type        = bool
  default     = true
}

variable "enable_request_count_alarm" {
  description = "Whether to enable request count alarm"
  type        = bool
  default     = true
}

variable "enable_response_time_alarm" {
  description = "Whether to enable response time alarm"
  type        = bool
  default     = true
}

variable "create_dashboard" {
  description = "Whether to create a CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Project = "ecommerce-app"
  }
}

variable "waf_web_acl_name" {
  description = "Name of the WAF WebACL for CloudWatch metrics"
  type        = string
  default     = ""
}

variable "waf_enabled" {
  description = "Whether WAF is enabled and should be included in the dashboard"
  type        = bool
  default     = false
}
