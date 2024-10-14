# Reuse the existing SNS Topic
resource "aws_sns_topic" "cpu_alarm_sns_topic" {
  name = "cpu-alarm-sns-topic"
}

# SNS Subscription (email notification)
resource "aws_sns_topic_subscription" "cpu_alarm_sns_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_sns_topic.arn
  protocol  = "email"
  endpoint  = "taeahmed@outlook.com"
}

# EC2 instance data sources for multiple instances
data "aws_instance" "depi_frontend_server" {
  filter {
    name   = "tag:Name"
    values = ["depi-frontend-server"]
  }
}

data "aws_instance" "depi_backend_server" {
  filter {
    name   = "tag:Name"
    values = ["depi-backend-server"]
  }
}

data "aws_db_instance" "depi-rds-instance" {
  filter {
    name   = "tag:Name"
    values = ["depi-rds-instance"]
  }
}

# CloudWatch Alarm for CPUUtilization > 80% (Frontend)
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_frontend" {
  alarm_name          = "depi-frontend-server-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 # 1 minute interval
  statistic           = "Average"
  threshold           = 80 # 80% CPU threshold
  alarm_description   = "High CPU utilization on depi-frontend-server (InstanceId: ${data.aws_instance.depi_frontend_server.id})"
  dimensions = {
    InstanceId = data.aws_instance.depi_frontend_server.id
  }
  treat_missing_data = "missing"

  alarm_actions = [
    aws_sns_topic.cpu_alarm_sns_topic.arn
  ]
}

# CloudWatch Alarm for CPUUtilization > 80% (Backend)
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_backend" {
  alarm_name          = "depi-backend-server-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 # 1 minute interval
  statistic           = "Average"
  threshold           = 80 # 80% CPU threshold
  alarm_description   = "High CPU utilization on depi-backend-server (InstanceId: ${data.aws_instance.depi_backend_server.id})"
  dimensions = {
    InstanceId = data.aws_instance.depi_backend_server.id
  }
  treat_missing_data = "missing"

  alarm_actions = [
    aws_sns_topic.cpu_alarm_sns_topic.arn
  ]
}

# CloudWatch Alarm for CPUUtilization > 80% (Database)
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_Database" {
  alarm_name          = "depi-rds-instance-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 # 1 minute interval
  statistic           = "Average"
  threshold           = 80 # 80% CPU threshold
  alarm_description   = "High CPU utilization on depi-rds-instance (InstanceId: ${data.aws_db_instance.depi-rds-instance.id})"
  dimensions = {
    InstanceId = data.aws_db_instance.depi-rds-instance.id
  }
  treat_missing_data = "missing"

  alarm_actions = [
    aws_sns_topic.cpu_alarm_sns_topic.arn
  ]
}
