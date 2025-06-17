resource "aws_s3_bucket" "image_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "ImageBucket"
  }
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { AWS = aws_iam_role.lambda_exec_role.arn },
        Action    = ["s3:PutObject"],
        Resource  = "${aws_s3_bucket.image_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = aws_vpc.vpc.id
          }
        }
      }
    ]
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = [aws_route_table.private.id]
  vpc_endpoint_type = "Gateway"
}


