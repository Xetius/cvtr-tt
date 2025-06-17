output "upload-endpoint" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}/${var.image_upload_route}"
}
