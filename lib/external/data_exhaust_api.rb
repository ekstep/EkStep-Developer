require 'pry'
require 'uri'
require 'net/http'

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
        request["content-type"] = 'application/json'
        request.body = "{\n    \"id\": \"ekstep.data_exhaust_authorize\",\n    \"ver\": \"1.0\",\n    \"ts\": \"2015-08-04T17:36:36+05:30\",\n    \"params\": {\n        \"requesterId\": \"\", \n        \"did\": \"ff305d54-85b4-341b-da2f-eb6b9e5460fa\",\n        \"key\": \"\",\n        \"msgid\": \"ff305d54-85b4-341b-da2f-eb6b9e5460fa\"\n    },\n    \"request\": {\n         \"licensekey\": \"f55e9009-79d9-4732-9864-83c3dad98f77\"\n    }\n}"
        @logger.info("DOWNLOADING DATA FROM DATA EXHAUST API. URL: #{url}")
        response = @http.request(request)
        @logger.info("DOWNLOADING SUCCESSFUL")
        response.read_body
      end
    end
  end
end