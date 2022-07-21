# Servidor rackspasce
# server "qa.api.sdc.caiena.net", user: "sdc", roles: %w{app db web sidekiq}

# set :sidekiq_service, 'qa.sdc-api.sidekiq.service'
# set :cron_user, 'sdc'

# set :repo_url, "https://github.com/caiena/sol-api.git"

# Servidor AWS
server "ec2-18-218-38-66.us-east-2.compute.amazonaws.com", user: "sol", roles: %w{app db web sidekiq}
set :sidekiq_service, 'production.sol-api.sidekiq.service'
set :cron_user, 'sol'
# set :rvm1_map_bins, %w{rake gem bundle ruby}

set :repo_url, "https://github.com/caiena/sol-api.git"
