resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = var.bucket_name
    Environment = "dev"
  }
}
