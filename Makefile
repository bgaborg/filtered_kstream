kinesis-put-records:
	docker-compose exec localstack awslocal kinesis put-records --cli-input-json file:///producer-kinesis/put_records.json

lambda-tail-log:
	aws logs --profile localstack --endpoint-url=http://localhost:4566  tail /aws/lambda/filter_lambda --follow

show-sqs-message-count:
	aws sqs \
		--profile localstack \
		--endpoint-url=http://localhost:4566 \
		get-queue-attributes \
		--queue-url http://localhost:4566/000000000000/local-lambda-mapping-failre-sqs \
		--attribute-names ApproximateNumberOfMessages \
		--query 'Attributes.ApproximateNumberOfMessages' \
		--output text

confirm-kinesis:
	aws kinesis --profile localstack --endpoint http://localhost:4566 describe-stream-summary --stream-name local-stream