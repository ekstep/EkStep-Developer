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

      def upload_data_files_to_s3(response_file)
        Zip::File.open(response_file.path) do |zip_file|
          zip_file.each do |entry|
            if entry.size > 0
              upload(entry)
            end
          end
        end
      end

      def upload(file)
        s3 = Aws::S3::Resource.new(region: @aws_region)
        @logger.info("UPLOADING FILE TO S3: #{file.name.split('/').last}")
        obj = s3.bucket(@s3_datasets_bucket).object(file.name.split('/').last)
        obj.put(body: file.get_input_stream.read)
      end
    end
  end
end