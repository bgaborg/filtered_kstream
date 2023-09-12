import base64
import logging
import os
import time
import boto3
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

bucket_name = os.getenv("BUCKET_NAME", "bucket_name")
s3_client = boto3.client('s3')


def lambda_handler(event, context):
    logger.info(f"bucket_name: {bucket_name}")

    if not "Records" in event:
        logger.info(f"event: {event}")
        raise ValueError("event does not contain Records")

    records = []
    for record in event['Records']:
        # Kinesis data is base64 encoded so decode here
        payload = base64.b64decode(record["kinesis"]["data"])
        records.append(payload)

    # convert records to dict from json
    records = [json.loads(record) for record in records]

    # get the current timestamp from the system in milliseconds
    current_time = round(time.time())

    # save records to s3 in a single file
    s3_client.put_object(
        Bucket=bucket_name,
        # key includes timestamp
        Key=f"records_{current_time}.json",
        Body=json.dumps(records)
    )

