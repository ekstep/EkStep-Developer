set :output, {:error => 'error.log', :standard => 'cron.log'}
set :environment_variable, 'EP_LOG_DIR'
set :environment, ENV['EP_LOG_DIR']

every 1.day, :at => '1:00 am' do
  rake "scheduled:ekstep_data_decrypt"
end
