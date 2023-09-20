import datetime
import json
import random
import uuid
import boto3

STREAM_NAME = "input_stream"
ENDPOINT_URL = "http://localhost:4566"


def get_data():
    return {
        'event_time': datetime.datetime.now().isoformat(),
        'ticker': random.choice(['AAPL', 'AMZN', 'MSFT', 'INTC', 'TBV']),
        'price': round(random.random() * 100, 2)
    }


def generate(stream_name, kinesis_client):
    #while True:
    for i in range(100):
        data = get_data()
        print(data)
        kinesis_client.put_record(
            StreamName=stream_name,
            Data=json.dumps(data),
            PartitionKey=uuid.uuid4().hex
        )


if __name__ == '__main__':
    session = boto3.Session(profile_name='localstack')
    kinesis_client = session.client(
        'kinesis',
        endpoint_url=ENDPOINT_URL,
        region_name='us-east-1'
        )
    generate(STREAM_NAME, kinesis_client)