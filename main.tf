terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = var.region
}

provider "aws" {
  region     = var.s3_replication_region
  alias      = "secondary"
}




data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_primary_bucket_name}/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

// Primary S3 bucket where xml file will be stored

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.s3_primary_bucket_name
  force_destroy = true

  tags = var.s3_tag
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json

}

resource "aws_s3_bucket_acl" "s3_bucket" {
  bucket = var.s3_primary_bucket_name
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "s3_bucket" {
  bucket = var.s3_primary_bucket_name
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "s3_bucket_logging" {
  bucket = aws_s3_bucket.s3_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "bucketlog/"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-bucket-config" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  rule {
    id     = "primarybucket"
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
}

// Resource to upload any new files to bucket, we can modify based on requirement

resource "aws_s3_object" "object" {
  depends_on   = [aws_s3_bucket_replication_configuration.primary]
  count        = var.upload_sample_file ? 1 : 0
  bucket       = aws_s3_bucket.s3_bucket.bucket
  key          = "file.xml"
  source       = "${path.module}/file.xml"
  content_type = "xml" 
  etag         = filemd5("${path.module}/file.xml")
}



