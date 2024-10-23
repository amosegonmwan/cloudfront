data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "lambda_sns_assume_role" {
  statement {
    sid    = "AllowLambdaAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "forward_email" {
  statement {
    sid    = "AllowLambdaCreateLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowLambdaToGetObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.website_bucket.arn}/*",
    ]
  }
  statement {
    sid    = "AllowLambdaToPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.main.arn
    ]
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src/lambda.zip"
}

#CF bucket policy
data "aws_iam_policy_document" "cf_policy" {
  statement {
    sid     = "AllowRootPolicy"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.website_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.website_bucket.bucket}/*"
    ]
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
  }
  statement {
    sid    = "AllowCloudFrontDistribution"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:GetObject", "s3:PutBucketPolicy"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.website_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.website_bucket.bucket}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.s3_distribution.arn
      ]
    }
  }
}


data "aws_iam_policy_document" "log_policy" {
  statement {
    sid    = "AllowCloudFrontDistribution"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.log_bucket.arn,
      "arn:aws:s3:::${aws_s3_bucket.log_bucket.bucket}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.s3_distribution.arn
      ]
    }
  }
}