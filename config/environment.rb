# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Load secrets to app from local_env.rb file
local_env = File.join(Rails.root, 'config', 'local_env.rb')
load(local_env) if File.exists?(local_env)

# Initialize the Rails application.
Bomberball::Application.initialize!
