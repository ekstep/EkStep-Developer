require 'pry'
require 'yaml'
require_relative './utils/ep_logging.rb'
require_relative '../lib/model/sync_date'
require_relative '../lib/core/data_sync_controller'
require_relative '../lib/external/data_exhaust_api'
require_relative '../lib/external/s3_client'
require_relative '../config/config'

module EkstepEcosystem
  module Jobs
    class DataSyncJob

      PROGNAME = 'ekstep_data_sync.jobs.ep'
      include EkstepEcosystem::Utils::EPLogging

      def self.perform
        begin
          logger.start_task
          config = Config.load
          api = DataExhaustApi.new(config.data_exhaust_api_endpoint, logger)
          s3_client = S3Client.new(config.aws_region,
                                   config.s3_datasets_bucket,
                                   logger)
          DataSyncController
              .new(SyncDate.new(config.data_dir, config.store_file_name, config.initial_download_date,
                                config.download_batch_size, logger),
                   config.dataset_id, config.resource_id, config.licence_key,
                   api, s3_client, logger)
              .sync()
          logger.end_task
        rescue => e
          logger.error(e, {backtrace: e.backtrace[0..4]})
          logger.end_task
        end
      end
    end
  end
end