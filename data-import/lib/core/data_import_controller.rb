require 'pry'
require 'tempfile'
require 'zip'
require 'aws-sdk'

module EkstepEcosystem
  module Jobs
    class DataImportController

      def initialize(import_date, dataset_id, resource_id, licence_key,
       data_exhaust_api, s3_client, logger)
      @import_date = import_date
      @data_exhaust_api = data_exhaust_api
      @logger = logger
      @dataset_id = dataset_id
      @resource_id = resource_id
      @licence_key = licence_key
      @s3_client = s3_client
    end

    def import
      begin
        from_date = @import_date.download_start_date
        to_date = @import_date.download_end_date

        if from_date >= Date.today
          @logger.info('NOTHING NEW TO DOWNLOAD, GOING AWAY')
          return
        end

        response = @data_exhaust_api.download(@dataset_id, @resource_id, from_date, to_date, @licence_key)
        response_file = save_response_to_file(response)

        Zip::File.open(response_file.path) do |zip_file|
          zip_file.each do |entry|
            if entry.file? && entry.name.end_with?(".gz")
              saved_entry = save_zip_entry_to_file(entry)
              Zip::File.open(saved_entry) do |sub_zip_file|
                sub_zip_file.each do |sub_entry|
                  upload_to_s3_if_file(sub_entry)
                end
              end
              File.delete(saved_entry)
            end
          end
        end

        @import_date.update(to_date)
        File.delete(response_file)
      rescue => e
        @logger.error("EXCEPTION: #{e}")
        return
      end while true
    end

    private
    def upload_to_s3_if_file(entry)
      if entry.file? && entry.name.end_with?('.gz')
        @s3_client.upload(entry.name, entry.get_input_stream.read)
      end
    end

    def save_response_to_file(response)
      response_file = Tempfile.new('data_exhaust_response')
      @logger.info("SAVING RESPONSE TO: #{response_file.path}")
      response_file.write(response)
      response_file.flush
      response_file
    end

    def save_zip_entry_to_file(zip_file_entry)
      dest_file = Tempfile.new('data_exhaust_response_zip_file')
      @logger.info("SAVING ZIP FILE TO: #{dest_file.path}")
      dest_file << zip_file_entry.get_input_stream.read
      dest_file.flush
      dest_file
    end

  end
end
end
