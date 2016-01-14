require 'pry'
require 'tempfile'
require 'zip'
require 'aws-sdk'

module EkstepEcosystem
  module Jobs
    class DataSyncController

      def initialize(sync_date, download_batch_size, dataset_id, resource_id, licence_key,
                     aws_region, s3_datasets_bucket, data_exhaust_api, logger)
        @sync_date = sync_date
        @download_batch_size = download_batch_size
        @data_exhaust_api = data_exhaust_api
        @logger = logger
        @dataset_id = dataset_id
        @resource_id = resource_id
        @licence_key = licence_key
        @aws_region = aws_region
        @s3_datasets_bucket = s3_datasets_bucket
      end

      def sync
        @logger.info("Syncing")
        begin
          from_date = @sync_date.download_start_date()
          to_date = @sync_date.download_end_date()
          if (from_date >= Date.today)
            @logger.info('NOTHING NEW TO DOWNLOAD, GOING AWAY')
            return
          end
          response = @data_exhaust_api.download(@dataset_id, @resource_id, from_date, to_date, @licence_key)

          response_file = Tempfile.new('data_exhaust_response')
          @logger.info("SAVING RESPONSE TO: #{response_file.path}")
          response_file.write(response)
          response_file.flush

          Zip::File.open(response_file.path) do |zip_file|
            zip_file.each do |entry|
              if entry.size > 0
                s3 = Aws::S3::Resource.new(region: @aws_region)
                @logger.info("UPLOADING FILE TO S3: #{entry.name.split('/').last}")
                obj = s3.bucket(@s3_datasets_bucket).object(entry.name.split('/').last)
                obj.put(body: entry.get_input_stream.read)
              end
            end
          end
          @sync_date.update(to_date)
        rescue => e
          @logger.error("EXCEPTION: #{e}")
        end while true
        #find till where the data is downloaded
        #initiate download for data from last download data, in batches
        #locally save the downloaded zip file
        #extract the zip file
        #upload each aggregate file to s3
        #update last downloaded date
        #clean up all temp files/directories created
      end
    end
  end
end