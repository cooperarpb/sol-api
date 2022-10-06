server "138.185.35.11", user: "sol", roles: %w{app db web sidekiq} # api.sol.cooperar.pb.gov.br
set :sidekiq_service, 'production.sol-api.sidekiq.service'
set :application, "sol-api"
set :stage, 'production'
set :cron_user, 'sol'
set :ssh_options, { port: 22011 }

set :repo_url, "https://github.com/caiena/sol-api.git"