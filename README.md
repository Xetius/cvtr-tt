# Convertr Technical Test
# Chris Hudson

Assumptions:
* Image will be sent as a base64 encoded parameter in the body of the request.

ChangeLog
* Configure AWS provider.  Using latest release version (5.99.1)
* Configured for my AWS account in eu-west-2
* Create VPC with no public IP address (CIDR 10.0.0.0/24)
* Associated 2 private subnets (CIDR 10.0.1.0/24 and 10.0.2.0/24)
* Create routing table and association
* Added a utility to encode in base64 and send it via HTTP POST to a URL
* Created a test image in jpeg format
