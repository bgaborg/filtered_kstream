import json
import base64
import logging
import os
import uuid
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

output_stream_name = os.getenv("STREAM_NAME", "stream_name")

print(f"Preparing the kinesis data stream client for stream '{output_stream_name}'")
kinesis_data_stream_client = boto3.client('kinesis')


def lambda_handler(event, context):
    logger.info(f"output_stream_name: {output_stream_name}")

    if not "Records" in event:
        logger.info(f"event: {event}")
        raise ValueError("event does not contain Records")

    for record in event['Records']:
        # Kinesis data is base64 encoded so decode here
        payload = base64.b64decode(record["kinesis"]["data"])
        try:
            payload = json.loads(payload)
            if payload["ticker"] == "AAPL":
                logger.info(f"Found AAPL ticker: {payload}")
                kinesis_data_stream_client.put_record(
                    StreamName=output_stream_name,
                    Data=json.dumps(payload),
                    PartitionKey=uuid.uuid4().hex
                )
        except json.JSONDecodeError as e:
            logger.info(f"Unable to decode payload: {payload}. Error: {e}")

        logger.info("Decoded payload: " + str(payload))
