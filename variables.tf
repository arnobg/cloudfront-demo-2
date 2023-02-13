

variable "region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "s3_replication_region" {
  type        = string
  default     = "eu-west-1"
  description = "The region your primary bucket will replicate to."
}

# S3 variables

variable "s3_primary_bucket_name" {
  description = "Name of the bucket to be deployed"
  default     = "myproject-cyberduck-s3"
  type        = string
}

variable "secondary_name" {
  description = "Secondary replication s3 bucket name"
  default     = "myproject-cyberduck-s3-replica"
  type        = string
}

variable "upload_sample_file" {
  default     = true
  description = "Upload sample xml file to s3 bucket"
}

variable "s3_tag" {
  description = "Tags to set on the s3 primary bucket."
  type        = map(string)
  default     = { "Name" = "S3 Primary Bucket", "created-by" = "terraform" }
}

variable "s3_replica_tag" {
  description = "Tags to set on the s3 replication bucket."
  type        = map(string)
  default     = { "Name" = "S3 Replication Bucket", "created-by" = "terraform" }
}

variable "s3_log_tag" {
  description = "Tags to set on the s3 log bucket."
  type        = map(string)
  default     = { "Name" = "S3 Log Bucket", "created-by" = "terraform" }
}


// CloudFront related variables

variable "use_cloudfront_domain" {
  description = "Use CloudFront primary address without Route53 and ACM certificate"
  type        = bool
  default     = false
}

variable "price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100" // Only US,Canada,Europe
}

variable "cf_tag" {
  description = "Tags to set on the CloudFront resource."
  type        = map(string)
  default     = { "Name" = "CloudFront_Distribution", "created-by" = "terraform" }
}

# All values for the TTL are important when uploading static content that changes
variable "cloudfront_min_ttl" {
  default     = 0
  description = "The minimum TTL for the cloudfront cache"
}

variable "cloudfront_default_ttl" {
  default     = 86400
  description = "The default TTL for the cloudfront cache"
}

variable "cloudfront_max_ttl" {
  default     = 31536000
  description = "The maximum TTL for the cloudfront cache"
}

# Cloud Watch alarm monitoring variables

variable "alarm_500_name" {
  default     = "500 Error alarm"
  description = "The alarm name for 500 errors"
}

variable "alarm_req_name" {
  default     = "File access requests alarm"
  description = "The alarm name for Requests count"
}



