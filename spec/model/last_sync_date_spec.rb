require 'pry'
require 'yaml'
require 'date'
require_relative '../lib/model/last_sync_date'

describe 'Last Sync Date' do

  before(:each) do
    @logger = spy('logger')
    @initial_download_date = Date.today.prev_month
    File.truncate(@store_file_path) rescue nil
    @store_file_path = File.join(ENV['HOME'], 'ekstepdatasynctest', 'store.yml')
    @last_sync_date = EkstepEcosystem::Jobs::LastSyncDate.new('ekstepdatasynctest', 'store.yml',
                                                              @initial_download_date, @logger)
  end

  it 'should download from configured initial date when last sync date is not present' do
    expect(@last_sync_date.get()).to eql(@initial_download_date)
  end

  it 'should return last download date when when present in store' do
    store_file = File.open(@store_file_path, "w")
    last_download_date = Date.today
    store_file.write({:last_sync_date => last_download_date}.to_yaml)
    store_file.close
    expect(@last_sync_date.get()).to eql(last_download_date)
  end

  it 'should return configured initial date when value in store is corrupt' do
    store_file = File.open(@store_file_path, "w")
    store_file.write({:last_sync_date => "currupt value date"}.to_yaml)
    store_file.close
    expect(@last_sync_date.get()).to eql(@initial_download_date)
  end

end