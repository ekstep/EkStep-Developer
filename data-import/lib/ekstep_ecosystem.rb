require 'pry'
require 'yaml'
require_relative '../lib/core/import_date'
require_relative '../lib/core/data_import_controller'
require_relative '../lib/external/data_exhaust_api'
require_relative '../lib/external/s3_client'
require_relative '../config/config'
require_relative '../../ep-logging/lib/ep_logging.rb'

module EkstepEcosystem
  module Jobs
    class DataImportJob

      PROGNAME = 'ekstep_data_import.jobs.ep'
      include EkstepEcosystem::Utils::EPLogging

      def self.perform
        begin
          logger.start_task
          config = Config.load
          api = DataExhaustApi.new(config.data_exhaust_api_endpoint, logger)
          s3_client = S3Client.new(config.aws_region,
                                   config.s3_datasets_bucket,
                                   logger)
          DataImportController
              .new(ImportDate.new(config.data_dir, config.store_file_name, config.initial_download_date,
                                  config.download_batch_size, logger),
                   config.dataset_id, config.resource_id, config.licence_key,
                   api, s3_client, logger)
              .import()
          logger.end_task
        rescue => e
          logger.error(e, {backtrace: e.backtrace[0..4]})
          logger.end_task
        end
      end
    end
  end
end
