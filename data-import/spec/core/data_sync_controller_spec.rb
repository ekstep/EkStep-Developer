require 'pry'
require 'yaml'
require 'date'
require 'timecop'
require_relative '../../lib/core/import_date'
require_relative '../../lib/core/data_import_controller'

describe 'Data Import Controller' do

  before(:each) do
    @logger = spy('logger')
    @data_exhaust_api = double('data_exhaust_api')
    @s3_client = double('s3_client')
    @initial_download_date = Date.new(2016, 01, 01)
    @download_batch_size = 1
    @store_file_path = File.join(ENV['HOME'], 'ekstepdataimporttest', 'store.yml')
    File.truncate(@store_file_path, 0) rescue nil
    @import_date = EkstepEcosystem::Jobs::ImportDate.new('ekstepdataimporttest', 'store.yml',
     @initial_download_date, @download_batch_size, @logger)
    @controller = EkstepEcosystem::Jobs::DataImportController.new(@import_date, 'dataset 1', 'resource id 1', 'licence key 1',
      @data_exhaust_api, @s3_client, @logger)
  end

  it 'should import data from initial date when previous import date is not present' do
    Timecop.freeze(Time.local(2016, 01, 02))
    response_file = File.open('./spec/mock_dataexhaust_response.zip')
    response_file_contents = response_file_contentss(response_file)
    expectDataExhaustAPIToBeCalled(response_file)
    expectDatasetFileToBeUploadedToS3(response_file_contents)

    @controller.import
  end

  def save_zip_entry_to_file(zip_file_entry)
    dest_file = Tempfile.new('data_exhaust_response_zip_file')
    @logger.info("SAVING ZIP FILE TO: #{dest_file.path}")
    dest_file << zip_file_entry.get_input_stream.read
    dest_file.flush
    dest_file
  end

  def response_file_contentss(response_file)
    response_file_contents = []
    Zip::File.open(response_file.path) do |zip_file|
      zip_file.each do |entry|
        if entry.file? && entry.name.end_with?(".gz")
          saved_entry = save_zip_entry_to_file(entry)
          Zip::File.open(saved_entry) do |sub_zip_file|
            sub_zip_file.each do |sub_entry|
              if sub_entry.file? && sub_entry.name.end_with?('.gz')
                response_file_contents << {
                  name: sub_entry.name,
                  contents: sub_entry.get_input_stream.read
                }
              end
            end
          end
          File.delete(saved_entry)
        end
      end
    end
    response_file_contents
  end

  def expectDataExhaustAPIToBeCalled(response_file)
    expect(@data_exhaust_api).to receive(:download).with('dataset 1', 'resource id 1',
     @initial_download_date,
     @initial_download_date,
     'licence key 1')
    .and_return(response_file.read)
  end

  def expectDatasetFileToBeUploadedToS3(response_file_contents)
    response_file_contents.each do |r|
      expect(@s3_client).to receive(:upload).with(r[:name], r[:contents])
    end
  end
end
