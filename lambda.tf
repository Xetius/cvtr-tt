data "archive_file" "lambda_zip" {
  type             = "zip"
  source_file      = "./lambda.py"
  output_file_mode = "0666"
  output_path      = "${path.module}/lambda.zip"
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
}

resource "aws_lambda_permission" "apigw_upload_lambda_perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}

