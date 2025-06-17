# Convertr Technical Test
# Chris Hudson

Assumptions:
* Image will be sent as a base64 encoded parameter in the body of the request.

# Structure
* A S3 bucket is used to store the images
* A Lambda (in Python) is used to receive POST data containing the image and other information, and reconstructs the image file and writes it to the S3 storage.
* API Gateway uses Lambda Integration to expose an endpoint and pass the data to the Lambda.

# Details
* Created a utility in Go that takes a local image file, and creates the following data Structure
```

{
  "filename": <filename>,
  "content": <base64 encoded contents of file>,
  "filetype": <content type>
}

```

* This is then posted to the generated API Gateway endpoint as POST data
* API Gateway endpoint is connected to the Lambda using Lambda Integration which provides a known JSON structure to the Python Lambda.
* The Python Lambda does the following:
  * Extracts the filename from the json structure.
  * Extracts the base64 encoded contents from the JSON structure.
  * Extracts the content-type of the image from the JSON structure.
  * Creates a byte array by decoding the base64 contents.
  * Create a unique filename by prepending a uuid to the filename.
  * Write the byte array to S3 with the new unique filename
  * Respond to the caller with a 200 code.

  If there is no filename or content then respond with a 400 error code.

# Execution
## Creating the sendimage utility

Inside the utilities directory, build the sendimage utility using:
```
go build sendimage.go
```
This will create the `sendimage` binary.  This will take the jpg image filename and post it to the API endpoint.

## Deploy AWS Infrastructure
To deploy the AWS infrastructure, run the following from the root of the git repository:
```
terraform init
terraform plan
terraform apply
export IMAGE_UPLOAD_URL$=(terraform output -raw upload-endpoint)
```

The final export line creates the environment variable that the sendimage executable uses to obtain the URL to sent the image to.

## Uploading an image
Execute the sendimage binary.
```
cd utilities
./sendimage test.jpg

```
You can also move the sendimage binary to somewhere in your current path.

This will upload the image to the S3 storage.

The content type is automatically detected and applied.  This is also passed as part of the post data.

# Conclusion

# TODO
Given more time I would do the following:
* Probably create user accounts using Cognito and link this to the authorisation using API keys
* Provide automation for AWS infrastructure deployment and updates.  This would be fairly simple using either GitHub Actions (as the code is in GitHub currently) or Code Build.

ChangeLog
* Configure AWS provider.  Using latest release version (5.99.1)
* Configured for my AWS account in eu-west-2
* Create VPC with no public IP address (CIDR 10.0.0.0/24)
* Associated 2 private subnets (CIDR 10.0.1.0/24 and 10.0.2.0/24)
* Create routing table and association
* Added a utility to encode in base64 and send it via HTTP POST to a URL
* Created a test image in jpeg format
* Created python lambda code to handle post request
* Create Lambda terraform code
* Create API Gateway
* Create Add Lambda Integration
