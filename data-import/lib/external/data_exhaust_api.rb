require 'pry'
require 'uri'
require 'net/http'
require 'securerandom'

module EkstepEcosystem
  module Jobs
    class DataExhaustApi
      def initialize(endpoint, logger)
        @endpoint = endpoint
        @http = Net::HTTP.new(URI(endpoint).host, URI(endpoint).port)
        @logger = logger
      end

      def download(dataset_id, resource_id,
                   from_date, to_date, licence_key)
        url = URI("#{@endpoint}/#{dataset_id}/#{resource_id}/#{from_date}/#{to_date}")
        request = Net::HTTP::Post.new(url)
        request['content-type'] = 'application/json'
        request.body = {
            :id => 'ekstep.data_exhaust_authorize',
            :ver => '1.0',
            :ts => Time.now.utc.strftime('%FT%T%:z'),
            :params => {
                :msgid => SecureRandom.uuid
            },
            :request => {:licensekey => "#{licence_key}"}
        }.to_json

        @logger.info("DOWNLOADING DATA FROM DATA EXHAUST API. URL: #{url}")
        response = @http.request(request)

        if response['content-type'] != 'application/zip'
          @logger.error("DOWNLOAD FAILED, error: #{response.read_body}")
          raise 'ERROR WHEN CALLING DATA EXHAUST API'
        end

        @logger.info('DOWNLOAD SUCCESSFUL')
        response.read_body
      end
    end
  end
end