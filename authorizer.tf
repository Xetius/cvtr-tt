data "archive_file" "authorizer_lambda" {
  type             = "zip"
  source_file      = "./authorizer.py"
  output_file_mode = "0666"
  output_path      = "authorizer_lambda.zip"
}

resource "aws_lambda_function" "allow_all_authorizer" {
  function_name    = "AllowAllAuthorizer"
  filename         = data.archive_file.authorizer_lambda.output_path
  source_code_hash = data.archive_file.authorizer_lambda.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec_role.arn
  depends_on       = [aws_iam_role.lambda_exec_role]
}

resource "aws_api_gateway_authorizer" "allow_all_authorizer" {
  name                             = "AllowAllAuthorizer"
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  authorizer_uri                   = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.allow_all_authorizer.arn}/invocations"
  authorizer_result_ttl_in_seconds = 0
  identity_source                  = "method.request.header.Authorization"
  type                             = "TOKEN"
}

resource "aws_lambda_permission" "apigw_authorizer_lambda_perm" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.allow_all_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*"

}

