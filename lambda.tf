data "archive_file" "lambda_zip" {
  type             = "zip"
  source_file      = "${path.module}/lambda.py"
  output_path      = "${path.module}/lambda.zip"
  output_file_mode = "0666"
}

resource "aws_security_group" "lambda_sg" {
  name   = "lambda-sg"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc_endpoint.s3]
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_s3_write" {
  name = "lambda-s3-write-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBuckets"],
        Resource = "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_write.arn
}

resource "aws_lambda_function" "upload_lambda" {
  function_name    = "upload-image-lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }

  vpc_config {
    subnet_ids         = [for s in aws_subnet.private : s.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

