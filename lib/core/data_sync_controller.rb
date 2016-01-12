module EkstepEcosystem
  module Jobs
    class DataSyncController

      def initialize(lastSyncDateStore, logger)
        @dataStore = lastSyncDateStore
        @logger = logger
      end

      def sync
        @logger.info("Syncing")
        #find till where the data is downloaded
        #initiate download for data from last download data, in batches
        #locally save the downloaded zip file
        #extract the zip file, to as many levels are required
        #delete the zip file, after extraction
        #update last downloaded date
      end
    end
  end
end