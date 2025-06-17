import base64
import json
import boto3
import os
import uuid

s3 = boto3.client("s3")
BUCKET_NAME = os.environ.get("BUCKET_NAME", "")


def lambda_handler(event, context):
    try:
        if event.get("isBase64Encoded"):
            body_bytes = base64.b64decode(event["body"])
        else:
            body_bytes = event["body"].encode("utf-8")

        body = json.loads(body_bytes)
        filename = os.path.basename(body.get("filename"))
        content = body.get("content")
        filetype = body.get("filetype")

        if not filename:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing filename", "received": event}),
            }

        if not content:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing image data", "received": event}),
            }

        image_bytes = base64.b64decode(content)
        target_filename = f"{uuid.uuid4()}-{filename}"

        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=target_filename,
            Body=image_bytes,
            ContentType=filetype,
        )

        return {
            "statusCode": 200,
            "body": json.dumps(
                {"message": "Image Uploaded", "filename": target_filename}
            ),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e), "received": event}),
        }
