resource "aws_s3_bucket" "image_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "ImageBucket"
  }
}
