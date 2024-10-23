resource "aws_sns_topic" "main" {
  name_prefix       = var.sns_topic_name
  display_name      = var.sns_topic_display_name
  kms_master_key_id = var.kms_master_key_id #tfsec:ignore:AWS016
  tags              = var.tags
}

resource "aws_sns_topic_policy" "main" {
  arn = aws_sns_topic.main.arn
  policy = jsonencode({
    Id      = "__default_policy_ID"
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "__default_statement_ID"
        Resource = aws_sns_topic.main.arn
        Effect   = "Allow"
        Principal = {
          AWS = "*"
        }
        Condition = {
          ArnLike = {
            "AWS:SourceArn" = aws_lambda_function.website_lambda.arn
          }
          StringEquals = {
            "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
          }
        }
        Action = [
          "SNS:Subscribe",
          "SNS:SetTopicAttributes",
          "SNS:RemovePermission",
          "SNS:Receive",
          "SNS:Publish",
          "SNS:ListSubscriptionsByTopic",
          "SNS:GetTopicAttributes",
          "SNS:DeleteTopic",
          "SNS:AddPermission",
        ]
      },
    ]
  })
}

resource "aws_sns_topic_subscription" "main" {
  count = max(length(var.sns_topic_subscriptions), 0)

  topic_arn = aws_sns_topic.main.arn
  protocol  = var.sns_topic_subscriptions[count.index]["protocol"]
  endpoint  = var.sns_topic_subscriptions[count.index]["endpoint"]
  endpoint_auto_confirms = lookup(
    var.sns_topic_subscriptions[count.index],
    "endpoint_auto_confirms",
    false,
  )
  raw_message_delivery = false
}


