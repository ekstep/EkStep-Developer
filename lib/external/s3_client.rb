require 'pry'
require 'tempfile'
require 'zip'
require 'aws-sdk'

module EkstepEcosystem
  module Jobs
    class S3Client

      def initialize(aws_region, s3_datasets_bucket, logger)
        @aws_region = aws_region
        @s3_datasets_bucket = s3_datasets_bucket
        @logger = logger
      end

      def upload(file_name, file_contents)
        s3 = Aws::S3::Resource.new(region: @aws_region)
        @logger.info("UPLOADING FILE TO S3: #{file_name.split('/').last}")
        obj = s3.bucket(@s3_datasets_bucket).object(file_name.split('/').last)
        obj.put(body: file_contents)
      end
    end
  end
end