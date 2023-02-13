
// Cloudfront default domain has been used to publicly access the xml. 

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
