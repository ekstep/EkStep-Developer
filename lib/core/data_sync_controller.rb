require 'pry'
require 'tempfile'
require 'zip'
require 'aws-sdk'

module EkstepEcosystem
  module Jobs
    class DataSyncController

      def initialize(sync_date, download_batch_size, dataset_id, resource_id, licence_key,
                     data_exhaust_api, s3_client, logger)
        @sync_date = sync_date
        @download_batch_size = download_batch_size
        @data_exhaust_api = data_exhaust_api
        @logger = logger
        @dataset_id = dataset_id
        @resource_id = resource_id
        @licence_key = licence_key
        @s3_client = s3_client
      end

      def sync
        @logger.info("Syncing")
        begin
          from_date = @sync_date.download_start_date
          to_date = @sync_date.download_end_date

          if from_date >= Date.today
            @logger.info('NOTHING NEW TO DOWNLOAD, GOING AWAY')
            return
          end

          response = @data_exhaust_api.download(@dataset_id, @resource_id, from_date, to_date, @licence_key)
          response_file = save_response_to_file(response)

          Zip::File.open(response_file.path) do |zip_file|
            zip_file.each do |file|
              upload_file_to_s3(file)
            end
          end

          @sync_date.update(to_date)
        rescue => e
          @logger.error("EXCEPTION: #{e}")
          return
        end while true
      end

      private
      def upload_file_to_s3(file)
        if file.size > 0
          @s3_client.upload(file)
        end
      end

      def save_response_to_file(response)
        response_file = Tempfile.new('data_exhaust_response')
        @logger.info("SAVING RESPONSE TO: #{response_file.path}")
        response_file.write(response)
        response_file.flush
        response_file
      end
    end
  end
end