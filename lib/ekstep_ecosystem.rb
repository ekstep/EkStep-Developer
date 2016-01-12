require 'pry'
require 'yaml'
require_relative './utils/ep_logging.rb'
require_relative '../lib/model/last_sync_date'
require_relative '../lib/core/data_sync_controller'
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
          DataSyncController
              .new(LastSyncDate.new(config.data_dir,
                                    config.store_file_name,
                                    config.initial_download_date,
                                    logger),
                   logger)
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