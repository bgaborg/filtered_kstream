# filtered_kstream

## AWS configuration
```
$ aws configure --profile localstack
AWS Access Key ID [None]: dummy
AWS Secret Access Key [None]: dummy
Default region name [None]: us-east-1
Default output format [None]: text

$ cat ~/.aws/credentials
[localstack]
aws_access_key_id = dummy
aws_secret_access_key = dummy

$ cat ~/.aws/config
[profile localstack]
region = us-east-1
output = text
```

## Initialize localstack and components
```bash
make package_lambdas
docker-compose up -d
docker-compose run --rm terraform init
docker-compose run --rm terraform plan
docker-compose run --rm terraform apply --auto-approve
```

## Confirm that input and output kinesis stream works
```
aws kinesis --profile localstack --endpoint http://localhost:4566 describe-stream-summary --stream-name input_stream
aws kinesis --profile localstack --endpoint http://localhost:4566 describe-stream-summary --stream-name output_stream
```

## Put record kinesis stream
```
python input_kinesis/generate_data.py
```

## Lambda functions package & deploy
```bash
make package_lambdas
make deploy_lambdas
```

## Invoke lambda function
```bash
docker-compose exec localstack bash -c "
awslocal lambda invoke --function-name filter_lambda --payload file:///input_kinesis/put_records.json /dev/null --log-type Tail --query 'LogResult' --output text |  base64 -d
"
```

## Tail follow logs lambda
```
lambda-filter-tail-log
lambda-consumer-tail-log
```
