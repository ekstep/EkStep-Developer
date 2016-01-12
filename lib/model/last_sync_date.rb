require 'pry'
require 'date'
require 'hashie'
require 'yaml'
require 'fileutils'

module EkstepEcosystem
  module Jobs
    class LastSyncDate

      def initialize(data_dir, store_file_name, initial_download_date, logger)
        @logger = logger
        @initial_download_date = initial_download_date
        @store_dir = File.join(ENV['HOME'], data_dir)
        @store_file_name = File.join(@store_dir, store_file_name)
      end

      def get
        return store.last_sync_date if store.last_sync_date.instance_of?(Date)
        @initial_download_date
      end

      private
      def store
        unless @store.nil?
          @logger.info("STORE: #{@store.to_s}")
          return @store
        end

        @logger.info("LOAD STORE FILE: #{@store_dir}")
        unless Dir.exists?(@store_dir)
          @logger.info("NO PREVIOUS STORE FILE FOUND")
          @logger.info("CREATING NEW STORE FILE")
          FileUtils::mkdir_p @store_dir
          File.new(@store_file_name, "w")
        end
        @store = Hashie::Mash.new YAML.load_file(@store_file_name)
      end
    end
  end
end
