// Bucket Replication configuration

resource "aws_s3_bucket_replication_configuration" "primary" {

  depends_on = [aws_s3_bucket_versioning.s3_bucket] // Explicitly depends on primary bucket versioning 

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.s3_bucket.bucket


  rule {
    id = aws_s3_bucket.replica_bucket.bucket

    filter {} # rule requires no filter but attribute needs to be specified

    status = "Enabled"

    delete_marker_replication {
      status = "Enabled"
    }

    source_selection_criteria {

      replica_modifications {
        status = "Enabled"
      }
    }
    
    destination {
      bucket = aws_s3_bucket.replica_bucket.arn
    }

  }
}


//s3 Assume Role to attach to Replication Role

data "aws_iam_policy_document" "s3-assume-role" {

  statement {
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

// IAM Policy for primary bucket

resource "aws_iam_role_policy" "replication-primary" {

  name   = "primary"
  role   = aws_iam_role.replication.name
  policy = data.aws_iam_policy_document.s3_bucket.json
}

// IAM Policy Document for primary bucket 

data "aws_iam_policy_document" "s3_bucket" {

  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    # Don't use Terraform reference to bucket's ARN here as this would produce a circular dependency:
    # bucket depends on role depends on policy depends on this data source depends on bucket's ARN
    resources = ["arn:aws:s3:::${var.s3_primary_bucket_name}"]
  }

  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

  // Don't use Terraform reference to bucket's ARN here as this would produce a circular dependency:
  // bucket depends on role depends on policy depends on this data source depends on bucket's ARN
    resources = ["arn:aws:s3:::${var.s3_primary_bucket_name}/*"]
  }
}

// IAM Policy for Replication Bucket 

resource "aws_iam_role_policy" "replication-secondary" {
  provider = aws.secondary
  name     = "secondary"
  role     = aws_iam_role.replication.name
  policy   = data.aws_iam_policy_document.replica_bucket.json
}

// IAM Policy document for Replication Bucket

data "aws_iam_policy_document" "replica_bucket" {
  provider = aws.secondary
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.replica_bucket.arn}/*"]
  }
}

// Create S3 replication bucket 

resource "aws_s3_bucket" "replica_bucket" {
  provider      = aws.secondary
  bucket        = var.secondary_name
  force_destroy = true
  tags          = var.s3_replica_tag
}

resource "aws_s3_bucket_acl" "replica_bucket" {
  provider = aws.secondary
  bucket   = var.secondary_name
  acl      = "public-read"
}

resource "aws_s3_bucket_versioning" "replica_bucket" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.replica_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "replica-bucket-config" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.replica_bucket.bucket

  rule {
    id     = "bucketreplica"
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


resource "aws_iam_role" "replication" {
  name = "s3-${var.s3_primary_bucket_name}-replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

