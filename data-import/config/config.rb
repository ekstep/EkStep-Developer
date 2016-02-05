require 'hashie'

module EkstepEcosystem
  module Jobs
    class Config
      def self.load
        config = YAML.load_file('config/config.yml')
        return Hashie::Mash.new config
      end
    end
  end
end
