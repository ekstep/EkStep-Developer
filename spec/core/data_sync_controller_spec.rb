require 'pry'
require 'yaml'
require 'date'
require_relative '../../lib/model/sync_date'
require_relative '../../lib/core/data_sync_controller'

describe 'Data Sync Controller' do

  before(:each) do
    @logger = spy('logger')
    @data_exhaust_api = double('data_exhaust_api')
    @initial_download_date = Date.today.prev_month
    File.truncate(@store_file_path) rescue nil
    @store_file_path = File.join(ENV['HOME'], 'ekstepdatasynctest', 'store.yml')
    last_sync_date = EkstepEcosystem::Jobs::SyncDate.new('ekstepdatasynctest', 'store.yml',
                                                         @initial_download_date, @logger)
    @controller = DataSyncController.new(last_sync_date, @data_exhaust_api, logger)
  end

  xit 'should sync data from initial date when previous sync date is not present' do
    @controller.sync()

    expect(@data_exhaust_api).to have_received(:fetch).with("data set id", 'hash_of_partner_id',
                                                            @initial_download_date, @initial_download_date + 5,
                                                            'partner_licence_key')
  end
end