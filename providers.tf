provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = "convertr-tech-test"
    }
  }
}
