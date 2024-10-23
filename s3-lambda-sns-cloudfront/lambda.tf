resource "aws_iam_role" "email" {
  name = "lambda-sns-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_sns_assume_role.json
}

resource "aws_iam_policy" "email_forward" {
  name        = "lambda_sns_policy"
  description = "IAM policy for email forwarding Lambda"

  policy = data.aws_iam_policy_document.forward_email.json
}



resource "aws_iam_role_policy_attachment" "email" {
  role       = aws_iam_role.email.name
  policy_arn = aws_iam_policy.email_forward.arn
}

#Lambda function
resource "aws_lambda_function" "website_lambda" {
  s3_bucket     = aws_s3_bucket.website_bucket.bucket
  s3_key        = aws_s3_object.lambda.key
  function_name = "website-notify"
  role          = aws_iam_role.email.arn
  handler       = "function.lambda_handler"
  runtime       = "python3.9"
  memory_size   = 1024
  timeout       = 30

  environment {
    variables = {
      WebS3Bucket = aws_s3_bucket.website_bucket.bucket
      TopicArn    = aws_sns_topic.main.arn
      Region      = data.aws_region.current.name
    }
  }
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.website_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.website_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]

  }
}

resource "aws_lambda_permission" "email" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.website_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.website_bucket.arn
}

#12. s3 lambda object
resource "aws_s3_object" "lambda" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "lambda.zip"
  source = data.archive_file.lambda.output_path

  etag = filemd5(data.archive_file.lambda.output_path)
}

