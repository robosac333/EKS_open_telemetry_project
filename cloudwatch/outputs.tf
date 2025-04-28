output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu_utilization.arn
}

output "low_cpu_alarm_arn" {
  description = "ARN of the low CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.low_cpu_utilization.arn
}

output "high_network_in_alarm_arn" {
  description = "ARN of the high network in alarm"
  value       = var.enable_network_alarms ? aws_cloudwatch_metric_alarm.high_network_in[0].arn : null
}

output "high_network_out_alarm_arn" {
  description = "ARN of the high network out alarm"
  value       = var.enable_network_alarms ? aws_cloudwatch_metric_alarm.high_network_out[0].arn : null
}

output "high_request_count_alarm_arn" {
  description = "ARN of the high request count alarm"
  value       = var.enable_request_count_alarm ? aws_cloudwatch_metric_alarm.high_request_count[0].arn : null
}

output "high_response_time_alarm_arn" {
  description = "ARN of the high response time alarm"
  value       = var.enable_response_time_alarm ? aws_cloudwatch_metric_alarm.high_target_response_time[0].arn : null
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : null
}
