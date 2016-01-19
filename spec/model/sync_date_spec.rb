require 'pry'
require 'yaml'
require 'date'
require_relative '../../lib/model/sync_date'

describe 'Sync Date' do

  before(:each) do
    @logger = spy('logger')
    @initial_download_date = Date.today.prev_month
    @download_batch_size = 3
    File.truncate(@store_file_path) rescue nil
    @store_file_path = File.join(ENV['HOME'], 'ekstepdatasynctest', 'store.yml')
    @sync_date = EkstepEcosystem::Jobs::SyncDate.new('ekstepdatasynctest', 'store.yml',
                                                     @initial_download_date, @download_batch_size, @logger)
  end


  describe 'Download Start Date' do
    it 'should be the configured initial date when last sync date is not present' do
      expect(@sync_date.download_start_date()).to eql(@initial_download_date)
    end

    it 'should be last sync date when when present in store' do
      store_file = File.open(@store_file_path, "w")
      last_download_date = Date.today
      store_file.write({:sync_date => last_download_date}.to_yaml)
      store_file.close
      expect(@sync_date.download_start_date()).to eql(last_download_date + 1)
    end

    it 'should be the configured initial date when value in store is corrupt' do
      store_file = File.open(@store_file_path, "w")
      store_file.write({:sync_date => "currupt value date"}.to_yaml)
      store_file.close
      expect(@sync_date.download_start_date()).to eql(@initial_download_date)
    end
  end

  describe 'Download End Date' do
    it 'should be start_date plus batch size' do
      expect(@sync_date.download_end_date()).to eql(Date.new(2015, 12, 16))
    end

    it 'should not be newer than yesterday' do
      @sync_date = EkstepEcosystem::Jobs::SyncDate.new('ekstepdatasynctest', 'store.yml',
                                                       Date.today - 2, @download_batch_size, @logger)
      expect(@sync_date.download_end_date()).to eql(Date.today.prev_day)
    end
  end
end