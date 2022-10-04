server "138.185.35.11", user: "sol", roles: %w{app db web sidekiq}
set :stage, 'production'
set :cron_user, 'sol'
set :sidekiq_service, 'production.sol-api.sidekiq.service'
set :ssh_options, { port: 22011 } 
set :repo_url, "https://github.com/caiena/sol-api.git"