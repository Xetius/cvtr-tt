variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "bucket_name" {
  type    = string
  default = "xetius-convertr-image-bucket"
}

variable "image_upload_route" {
  type    = string
  default = "upload"
}
