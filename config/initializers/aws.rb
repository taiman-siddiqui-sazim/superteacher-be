require "aws-sdk-s3"

Aws.config.update(
  endpoint: "http://localhost:4566",
  access_key_id: "foo",
  secret_access_key: "bar",
  force_path_style: true,
  region: "us-east-1"
)

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV["AWS_BUCKET_NAME"])
