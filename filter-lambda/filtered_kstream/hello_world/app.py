import json
import base64
import logging
import os
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

stream_name = os.getenv("STREAM_NAME", "pdx-dev-dap-kinesis")

logger.info(f"Preparing the kinesis data stream client for stream '{stream_name}'")
kinesis_data_stream_client = boto3.client('kinesis')


def lambda_handler(event, context):
    if not "Records" in event:
        print(f"event: {event}")
        raise ValueError("event does not contain Records")
    for record in event['Records']:
        # Kinesis data is base64 encoded so decode here
        payload = base64.b64decode(record["kinesis"]["data"])
        try:
            payload = json.loads(payload)
        except json.JSONDecodeError as e:
            print(f"Unable to decode payload: {payload}. Error: {e}")
            raise e

        print("Decoded payload: " + str(payload))
