task :default => :console

namespace :scheduled do
  task :ekstep_data_sync do
    require_relative 'lib/ekstep_ecosystem.rb'
    EkstepEcosystem::Jobs::DataSyncJob.perform()
  end
end