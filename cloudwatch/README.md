# CloudWatch Module for Auto Scaling

This module sets up CloudWatch alarms to trigger scaling events for an Auto Scaling Group.

## Features

- CPU utilization alarms (high and low)
- Network traffic alarms (in and out)
- Application Load Balancer request count alarm
- Application Load Balancer response time alarm
- CloudWatch dashboard for monitoring

## Usage

```hcl
module "cloudwatch" {
  source                  = "./cloudwatch"
  prefix                  = "ecommerce"
  aws_region              = "us-east-1"
  autoscaling_group_name  = module.loadbalancer.autoscaling_group_name
  scale_out_policy_arn    = module.loadbalancer.scale_out_policy_arn
  scale_in_policy_arn     = module.loadbalancer.scale_in_policy_arn
  load_balancer_arn_suffix = module.loadbalancer.load_balancer_arn_suffix

  # Alarm thresholds
  high_cpu_threshold      = 70
  low_cpu_threshold       = 30
  high_network_threshold  = 5000000
  high_request_count_threshold = 1000
  high_response_time_threshold = 1

  # Evaluation settings
  evaluation_periods      = 2
  period                  = 300

  # Enable/disable specific alarms
  enable_network_alarms   = true
  enable_request_count_alarm = true
  enable_response_time_alarm = true

  # Create a dashboard
  create_dashboard        = true

  tags = {
    Project = "ecommerce-app"
  }
}
```

## Inputs

| Name                         | Description                                            | Type          | Default                         | Required |
| ---------------------------- | ------------------------------------------------------ | ------------- | ------------------------------- | :------: |
| prefix                       | Prefix to be used for resource names                   | `string`      | `"ecommerce"`                   |    no    |
| aws_region                   | AWS region where resources will be created             | `string`      | `"us-east-1"`                   |    no    |
| autoscaling_group_name       | Name of the Auto Scaling Group to monitor              | `string`      | n/a                             |   yes    |
| scale_out_policy_arn         | ARN of the scaling policy to execute when scaling out  | `string`      | n/a                             |   yes    |
| scale_in_policy_arn          | ARN of the scaling policy to execute when scaling in   | `string`      | n/a                             |   yes    |
| load_balancer_arn_suffix     | ARN suffix of the load balancer to monitor             | `string`      | `""`                            |    no    |
| evaluation_periods           | Number of periods to evaluate for the alarm            | `number`      | `2`                             |    no    |
| period                       | Duration in seconds over which the metric is evaluated | `number`      | `300`                           |    no    |
| high_cpu_threshold           | Threshold for high CPU utilization alarm               | `number`      | `70`                            |    no    |
| low_cpu_threshold            | Threshold for low CPU utilization alarm                | `number`      | `30`                            |    no    |
| high_network_threshold       | Threshold for high network traffic alarm (in bytes)    | `number`      | `5000000`                       |    no    |
| high_request_count_threshold | Threshold for high request count alarm                 | `number`      | `1000`                          |    no    |
| high_response_time_threshold | Threshold for high response time alarm (in seconds)    | `number`      | `1`                             |    no    |
| enable_network_alarms        | Whether to enable network traffic alarms               | `bool`        | `true`                          |    no    |
| enable_request_count_alarm   | Whether to enable request count alarm                  | `bool`        | `true`                          |    no    |
| enable_response_time_alarm   | Whether to enable response time alarm                  | `bool`        | `true`                          |    no    |
| create_dashboard             | Whether to create a CloudWatch dashboard               | `bool`        | `true`                          |    no    |
| tags                         | Tags to apply to all resources                         | `map(string)` | `{ Project = "ecommerce-app" }` |    no    |

## Outputs

| Name                         | Description                           |
| ---------------------------- | ------------------------------------- |
| high_cpu_alarm_arn           | ARN of the high CPU utilization alarm |
| low_cpu_alarm_arn            | ARN of the low CPU utilization alarm  |
| high_network_in_alarm_arn    | ARN of the high network in alarm      |
| high_network_out_alarm_arn   | ARN of the high network out alarm     |
| high_request_count_alarm_arn | ARN of the high request count alarm   |
| high_response_time_alarm_arn | ARN of the high response time alarm   |
| dashboard_arn                | ARN of the CloudWatch dashboard       |

## Alarms

### CPU Utilization Alarms

- **High CPU Utilization**: Triggers when the average CPU utilization exceeds the `high_cpu_threshold` for `evaluation_periods` consecutive periods of `period` seconds.
- **Low CPU Utilization**: Triggers when the average CPU utilization falls below the `low_cpu_threshold` for `evaluation_periods` consecutive periods of `period` seconds.

### Network Traffic Alarms (Optional)

- **High Network In**: Triggers when the average network in traffic exceeds the `high_network_threshold` for `evaluation_periods` consecutive periods of `period` seconds.
- **High Network Out**: Triggers when the average network out traffic exceeds the `high_network_threshold` for `evaluation_periods` consecutive periods of `period` seconds.

### Application Load Balancer Alarms (Optional)

- **High Request Count**: Triggers when the sum of requests exceeds the `high_request_count_threshold` for `evaluation_periods` consecutive periods of `period` seconds.
- **High Response Time**: Triggers when the average response time exceeds the `high_response_time_threshold` for `evaluation_periods` consecutive periods of `period` seconds.

## Dashboard

If `create_dashboard` is set to `true`, a CloudWatch dashboard will be created with the following widgets:

- EC2 CPU Utilization
- EC2 Network Traffic (In and Out)
- ALB Request Count
- ALB Response Time
