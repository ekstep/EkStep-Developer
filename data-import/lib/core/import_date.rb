require 'pry'
require 'date'
require 'hashie'
require 'yaml'
require 'fileutils'

module EkstepEcosystem
  module Jobs
    class ImportDate

      def initialize(data_dir, store_file_name, initial_download_date, download_batch_size, logger)
        @logger = logger
        @initial_download_date = initial_download_date
        @store_dir = File.join(ENV['HOME'], data_dir)
        @store_file_name = File.join(@store_dir, store_file_name)
        @download_batch_size = download_batch_size
      end

      def download_start_date
        return store.import_date + 1 if store.import_date.instance_of?(Date)
        @initial_download_date
      end

      def download_end_date
        (download_start_date() + (@download_batch_size - 1) > Date.today.prev_day) ?
            Date.today.prev_day :
            download_start_date() + (@download_batch_size -1)
      end

      def update(new_import_date)
        @logger.info("UPDATING IMPORT DATE TO: #{new_import_date}")
        store.import_date = new_import_date
        store_file = File.open(@store_file_name, "w")
        @logger.info("UPDATED STORE: #{YAML.dump(@store.to_hash)}")
        store_file.write(YAML.dump(@store.to_hash))
        store_file.flush
      end

      private
      def store
        unless @store.nil?
          return @store
        end
        @store = read_store_file()
        @logger.info("STORE: #{@store.to_hash}")
        return @store
      end

      def read_store_file
        @logger.info("LOAD STORE FILE: #{@store_dir}")
        unless Dir.exists?(@store_dir) && File.exists?(@store_file_name)
          @logger.info('NO PREVIOUS STORE FILE FOUND')
          @logger.info('CREATING NEW STORE FILE')
          FileUtils::mkdir_p @store_dir
          File.new(@store_file_name, 'w')
        end
        Hashie::Mash.new YAML.load_file(@store_file_name)
      end
    end
  end
end
