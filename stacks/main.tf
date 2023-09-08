# backend
terraform {
  backend "local" {}
}

# provider
provider "aws" {
  region = "us-east-1"

  access_key = "mock_access_key"
  secret_key = "mock_secret_key"

  s3_use_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cloudwatchlogs = "http://localstack:4566"
    iam      = "http://localstack:4566"
    kinesis  = "http://localstack:4566"
    firehose = "http://localstack:4566"
    lambda   = "http://localstack:4566"
    s3       = "http://localstack:4566"
    sqs      = "http://localstack:4566"
  }
}
