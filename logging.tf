// S3 bucket for logging from primary bucket and CloudFront

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = "logs-${var.s3_primary_bucket_name}"
  acl    = "log-delivery-write"
}


resource "aws_s3_bucket_versioning" "s3_log_bucket" {
  bucket = "logs-${var.s3_primary_bucket_name}"
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = "logs-${var.s3_primary_bucket_name}"
  tags          = var.s3_log_tag
  force_destroy = true
}

// Configure log bucket lifecycle rules

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.log_bucket.bucket

  rule {
    id = "bucketlog"

    expiration {
      days = 90
    }

    filter {
      prefix = "bucketlog/"
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }

  rule {
    id = "cflog"

    expiration {
      days = 180
    }

    filter {
      prefix = "cloudfront/"
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}
