resource "aws_kinesis_stream" "input_stream" {
  name             = "input_stream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_kinesis_stream" "output_stream" {
  name             = "output_stream"
  shard_count      = 1
  retention_period = 24
}

// DLQ
resource "aws_sqs_queue" "filter_lambda_mapping_failre_sqs" {
  name = "local_lambda_mapping_failre_sqs"
  message_retention_seconds = 345600 # 4 days
  visibility_timeout_seconds = 120
}

resource "aws_lambda_event_source_mapping" "local_mapping" {
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
  filename      = "build/filter_lambda.zip"
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

# resource "aws_lambda_function" "consumer_lambda" {
#   filename      = "build/consumer_lambda.zip"
#   function_name = "consumer_lambda"
#   role          = aws_iam_role.local_role.arn
#   handler       = "app.lambda_handler"
#   runtime       = "python3.11"
#   timeout = 60
# }

resource "aws_iam_role" "local_role" {
  name               = "local_role"
  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": "lambda.amazonaws.com"
			},
			"Effect": "Allow",
			"Sid": ""
		}
	]
}
EOF
}

resource "aws_iam_policy" "local_policy" {
  name   = "local_iam_policy"
  policy = data.aws_iam_policy_document.local_policy_document.json
}

data "aws_iam_policy_document" "local_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutBucketNotification",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "sqs:SendMessage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "local_poilcy_attachment" {
  role       = aws_iam_role.local_role.name
  policy_arn = aws_iam_policy.local_policy.arn
}

resource "aws_s3_bucket" "local_archive" {
  bucket = "local-archive"
}

resource "aws_s3_bucket_versioning" "local_archive_versioning" {
  bucket = aws_s3_bucket.local_archive.bucket
  versioning_configuration {
    status = "Enabled"
  }
}
