require 'pry'
require 'yaml'
require 'date'
require 'timecop'
require_relative '../../lib/model/sync_date'
require_relative '../../lib/core/data_sync_controller'

describe 'Data Sync Controller' do


  before(:each) do
    @logger = spy('logger')
    @data_exhaust_api = double('data_exhaust_api')
    @s3_client = double('s3_client')
    @initial_download_date = Date.new(2016, 01, 01)
    @download_batch_size = 1
    @store_file_path = File.join(ENV['HOME'], 'ekstepdatasynctest', 'store.yml')
    File.truncate(@store_file_path, 0) rescue nil
    @sync_date = EkstepEcosystem::Jobs::SyncDate.new('ekstepdatasynctest', 'store.yml',
                                                     @initial_download_date, @download_batch_size, @logger)
    @controller = EkstepEcosystem::Jobs::DataSyncController.new(@sync_date, 'dataset 1', 'resource id 1', 'licence key 1',
                                                                @data_exhaust_api, @s3_client, @logger)
  end

  it 'should sync data from initial date when previous sync date is not present' do
    Timecop.freeze(Time.local(2016, 01, 02))
    response_file = File.open('./spec/mock_dataexhaust_response.zip')
    extracted_response_file = get_extracted_response_file_content(response_file)
    expectDataExhaustAPIToBeCalled(response_file)
    expectDatasetFileToBeUploadedToS3(extracted_response_file)

    @controller.sync
  end

  def get_extracted_response_file_content(response_file)
    Zip::File.open(response_file.path) do |zip_file|
      zip_file.each do |entry|
        if entry.file?
          return entry.get_input_stream.read
        end
      end
    end
  end

  def expectDataExhaustAPIToBeCalled(response_file)
    expect(@data_exhaust_api).to receive(:download).with('dataset 1', 'resource id 1',
                                                         @initial_download_date,
                                                         @initial_download_date,
                                                         'licence key 1')
                                     .and_return(response_file.read)
  end

  def expectDatasetFileToBeUploadedToS3(aggregated_file)
    expect(@s3_client).to receive(:upload).with("dataset-2016-01-01-to-2016-01-01-041595063/aggregated-2016-01-01.gz",
                                                aggregated_file)
  end
end