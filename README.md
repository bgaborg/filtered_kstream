# filtered_kstream

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

init
```bash
$ make -C filter_lambda package
$ docker-compose up -d
$ docker-compose run --rm terraform init
$ docker-compose run --rm terraform plan
$ docker-compose run --rm terraform apply --auto-approve
```

confirm kinesis stream
```
aws kinesis --profile localstack --endpoint http://localhost:4566 describe-stream-summary --stream-name local-stream
```

put record kinesis stream
```
make kinesis-put-records
```

lambda function package & deploy
```bash
make -C consumer package
make -C consumer deploy
```

invoke lambda function
```bash
docker-compose exec localstack bash -c "
awslocal lambda invoke --function-name local-lambda --payload file:///consumer/lambda_invoke_payload.json /dev/null --log-type Tail --query 'LogResult' --output text |  base64 -d
"
```

tail follow logs lambda
```
make lambda-tail-log
```
