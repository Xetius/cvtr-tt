import base64
import json
import boto3
import os
import uuid
import logging

s3 = boto3.client("s3")
BUCKET_NAME = os.environ.get("BUCKET_NAME", "")


def lambda_handler(event, context):
    try:
        logger = logging.getLogger()
        logger.setLevel("INFO")

        body = json.loads(event.get("body", "{}"))
        filename = body.get("filename")
        content = body.get("content")

        logger.debug(f"filename: {filename}")
        logger.debug(f"content: {content}")

        if not filename:
            return {
                "statusCode": 400,
                "body": json.dumps({"error", "Missing filename"}),
            }

        if not content:
            return {
                "statusCode": 400,
                "body": json.dumps({"error", "Missing image data"}),
            }

        image_bytes = base64.b64decode(content)
        target_filename = f"{uuid.uuid4()}-{filename}"

        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=target_filename,
            Body=image_bytes,
            ContentType="image/jpeg",
        )

        return {
            "statusCode": 200,
            "body": json.dumps(
                {"message": "Image Uploaded", "filename": target_filename}
            ),
        }
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
