package:
	echo "package python lambda"
	mkdir package
	pip install -r requirements.txt -t package
	cp -r src/* package/
	mkdir -p ../stacks/build/
	cd package && zip -r ../../stacks/build/consumer_lambda.zip .
	rm -rf package

clean:
	rm -rf package
	rm -rf ../../stacks/build/consumer_lambda.zip

deploy:
	aws lambda --endpoint http://localhost:4566 --profile localstack \
	update-function-code --function-name="consumer_lambda" \
	--zip-file fileb://../stacks/build/consumer_lambda.zip