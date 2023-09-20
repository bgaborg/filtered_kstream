locals {
  consumer_lambda_filename = "consumer_lambda.zip"
  filter_lambda_filename = "filter_lambda.zip"
  consumer_lambda_file_path = "build/${local.consumer_lambda_filename}"
  filter_lambda_file_path = "build/${local.filter_lambda_filename}"
}

resource "aws_lambda_event_source_mapping" "filter_lambda_mapping" {
  event_source_arn                   = aws_kinesis_stream.input_stream.arn
  function_name                      = aws_lambda_function.filter_lambda.arn
  starting_position                  = "LATEST"
  maximum_retry_attempts             = 3
  batch_size                         = 100
  maximum_batching_window_in_seconds = 5
  maximum_record_age_in_seconds = 60
  bisect_batch_on_function_error = true
  destination_config {
    on_failure {
      destination_arn = aws_sqs_queue.filter_lambda_mapping_failre_sqs.arn
    }
  }
}

resource "aws_lambda_function" "filter_lambda" {
  filename = "${local.filter_lambda_file_path}"
  source_code_hash = filebase64sha256(local.filter_lambda_file_path)
  function_name = "filter_lambda"
  role          = aws_iam_role.local_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.11"
  timeout = 60

  environment {
    variables = {
      STREAM_NAME = "${aws_kinesis_stream.output_stream.name}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "consumer_lambda_mapping" {
  event_source_arn                   = aws_kinesis_stream.output_stream.arn
  function_name                      = aws_lambda_function.consumer_lambda.arn
  starting_position                  = "LATEST"
  maximum_retry_attempts             = 3
  batch_size                         = 100
  maximum_batching_window_in_seconds = 5
  maximum_record_age_in_seconds = 60
  bisect_batch_on_function_error = true
  destination_config {
    on_failure {
      destination_arn = aws_sqs_queue.filter_lambda_mapping_failre_sqs.arn
    }
  }
}

resource "aws_lambda_function" "consumer_lambda" {
  filename = "${local.consumer_lambda_file_path}"
  source_code_hash = filebase64sha256(local.consumer_lambda_file_path)
  function_name = "consumer_lambda"
  role          = aws_iam_role.local_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.11"
  timeout = 60

  environment {
    variables = {
      BUCKET_NAME = "${aws_s3_bucket.local_archive.bucket}"
    }
  }
}
