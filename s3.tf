# S3 Bucket for Artifactory Filestore
resource "aws_s3_bucket" "artifactory_filestore" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "${var.additional_tags}-filestore"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "artifactory_filestore_versioning" {
  bucket = aws_s3_bucket.artifactory_filestore.id
  versioning_configuration {
    status = var.s3_bucket_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "artifactory_filestore_encryption" {
  bucket = aws_s3_bucket.artifactory_filestore.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "artifactory_filestore_access" {
  bucket = aws_s3_bucket.artifactory_filestore.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "artifactory_s3_policy" {
  name = "artifactory-s3-filestore-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:ListAllMyBuckets",
          "s3:HeadBucket",
          "s3:CreateBucket"
        ]
        Resource = [
          aws_s3_bucket.artifactory_filestore.arn,
          "${aws_s3_bucket.artifactory_filestore.arn}/*"
        ]
      }
    ]
  })
}

# Attach S3 Policy to Artifactory Role
resource "aws_iam_role_policy_attachment" "artifactory_s3_policy_attachment" {
  role       = aws_iam_role.artifactory_role.name
  policy_arn = aws_iam_policy.artifactory_s3_policy.arn
}
