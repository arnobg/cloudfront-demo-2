
// Cloudwatch Alarms

resource "aws_cloudwatch_metric_alarm" "cloudfront-500-errors" {
  alarm_name          = var.alarm_500_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.sns_error_topic.arn]
  actions_enabled     = true

  dimensions = {
    DistributionId = aws_cloudfront_distribution.s3_distribution.id
    Region         = "Global"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront-request-alert" {
  alarm_name          = var.alarm_req_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Requests"
  namespace           = "AWS/CloudFront"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.sns_alert_topic.arn]
  actions_enabled     = true

  dimensions = {
    DistributionId = aws_cloudfront_distribution.s3_distribution.id
    Region         = "Global"
  }
}

// Used SMS alerting for cloudwatch alarms, can use this if already have any verified number, or can be altered to use mail notifications
locals {
  phone_numbers = ["+44xxxxxxxxxx"]
}

// SNS Topic/subscriber with CW 500 error metric alarm

resource "aws_sns_topic" "sns_error_topic" {
  name = "sns_error_topic"
}


resource "aws_sns_topic_subscription" "error_topic_sms_subscription" {
  count     = length(local.phone_numbers)
  topic_arn = aws_sns_topic.sns_error_topic.arn
  protocol  = "sms"
  endpoint  = local.phone_numbers[count.index]
}

// SNS Topic/subscriber with CW Request alert metric alarm

resource "aws_sns_topic" "sns_alert_topic" {
  name = "sns_alert_topic"
}


resource "aws_sns_topic_subscription" "alert_topic_sms_subscription" {
  count     = length(local.phone_numbers)
  topic_arn = aws_sns_topic.sns_alert_topic.arn
  protocol  = "sms"
  endpoint  = local.phone_numbers[count.index]
}
