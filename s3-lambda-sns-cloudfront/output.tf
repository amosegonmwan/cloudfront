output "cloud_front" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

#output "generated_policy" {
#  value = data.aws_iam_policy_document.cf_policy.json
#}