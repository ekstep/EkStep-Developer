require 'pry'
require 'yaml'
require 'date'
require_relative '../../lib/core/import_date'

describe 'Import Date' do

  before(:each) do
    @logger = spy('logger')
    @initial_download_date = Date.today.prev_month
    @download_batch_size = 3
    @store_file_path = File.join(ENV['HOME'], 'ekstepdataimporttest', 'store.yml')
    File.truncate(@store_file_path, 0) rescue nil
    @import_date = EkstepEcosystem::Jobs::ImportDate.new('ekstepdataimporttest', 'store.yml',
                                                         @initial_download_date, @download_batch_size, @logger)
  end


  describe 'Download Start Date' do
    it 'should be the configured initial date when last import date is not present' do
      expect(@import_date.download_start_date()).to eql(@initial_download_date)
    end

    it 'should be last import date when when present in store' do
      store_file = File.open(@store_file_path, "w")
      last_download_date = Date.today
      store_file.write({:import_date => last_download_date}.to_yaml)
      store_file.close
      expect(@import_date.download_start_date()).to eql(last_download_date + 1)
    end

    it 'should be the configured initial date when value in store is corrupt' do
      store_file = File.open(@store_file_path, "w")
      store_file.write({:import_date => "currupt value date"}.to_yaml)
      store_file.close
      expect(@import_date.download_start_date()).to eql(@initial_download_date)
    end
  end

  describe 'Download End Date' do
    it 'should be start_date plus batch size' do
      expect(@import_date.download_end_date()).to eql(@initial_download_date + @download_batch_size -1)
    end

    it 'should not be newer than yesterday' do
      @import_date = EkstepEcosystem::Jobs::ImportDate.new('ekstepdataimporttest', 'store.yml',
                                                           Date.today - 2, @download_batch_size, @logger)
      expect(@import_date.download_end_date()).to eql(Date.today.prev_day)
    end
  end
end