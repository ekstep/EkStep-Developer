task :default => :console

namespace :scheduled do
  task :ekstep_data_import do
    require_relative 'lib/ekstep_ecosystem.rb'
    EkstepEcosystem::Jobs::DataImportJob.perform()
  end
end


begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end