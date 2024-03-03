# Create a S3 bucket with name as a variable
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.s3name
}
# The rule specifies that the object ownership setting for the bucket, 
# This means that when objects are uploaded to the bucket,their ownership will default to the bucket owner.
resource "aws_s3_bucket_ownership_controls" "my_rule" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
# This configuration creates an AWS S3 bucket public access block 
# This ensuring that public access is restricted for the specified bucket
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
# This configuration sets up an AWS S3 bucket ACL
# It ensures that anyone can read the objects stored in the bucket.
resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my_rule,
    aws_s3_bucket_public_access_block.public,
  ]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read"
}
# This configuration uploads the local file named "index.html" to the S3 bucket 
resource "aws_s3_object" "index"{
  bucket = aws_s3_bucket.my_bucket.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}
# This configuration uploads the local file named "error.html" to the S3 bucket 
resource "aws_s3_object" "error"{
  bucket = aws_s3_bucket.my_bucket.id
  key = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

# This configuration sets up a website configuration for an S3 bucket
# It specifies the index document as "index.html" and the error document as "error.html"
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_acl.acl]
  
}
