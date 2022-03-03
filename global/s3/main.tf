terraform {
  backend "s3" {
    bucket = "tass-terraform-up-and-running-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create a bucket for storing terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "tass-terraform-up-and-running-state"

  lifecycle {
    prevent_destroy = true
  }
}

# Make the bucket private
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

# Keep old versions of items
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Keep those old versions for 90 days
resource "aws_s3_bucket_lifecycle_configuration" "bucket_versioning_config" {
  # Implicit dependency so that the versioning is created before these rules
  bucket = aws_s3_bucket_versioning.bucket_versioning.bucket
  rule {
    id = "all"

    expiration {
      days = 90
    }

    status = "Enabled"
  }
}

# Enable encryption on the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
