resource "aws_sns_topic" "alerts" {
  name = "SilentScalperAlerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "allenzopauljr@outlook.com"
}