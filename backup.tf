// Resources for configuring AWS Backup for S3 objects


resource "aws_backup_plan" "s3_backup" {
  name = "tf_s3_backup_plan"

  rule {
    rule_name         = "tf_s3_backup_rule"
    target_vault_name = aws_backup_vault.s3_backup.name
    schedule          = "cron(20 13 * * ? *)" // Please modify as required

    lifecycle {
      delete_after = 14
    }
  }
}

resource "aws_backup_vault" "s3_backup" {
  name          = "s3_backup_vault"
  force_destroy = true //Need to add this or else after a successful backup job run this will fail due to existing recovery points
}


resource "aws_backup_selection" "s3_backup" {
  iam_role_arn = aws_iam_role.s3_backup.arn
  name         = "tf_s3_backup_selection"
  plan_id      = aws_backup_plan.s3_backup.id

  resources = [
    aws_s3_bucket.s3_bucket.arn
  ]
}

resource "aws_iam_role" "s3_backup" {
  name = "s3_backup-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : ["sts:AssumeRole"],
        "Effect" : "allow",
        "Principal" : {
          "Service" : ["backup.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_backup" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.s3_backup.name
}
