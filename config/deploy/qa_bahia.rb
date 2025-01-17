# Servidor QA da CAR-BA
server "10.70.1.51", user: "sol", roles: %w{app db web sidekiq}
set :sidekiq_service, 'production.sol-api.sidekiq.service'
set :cron_user, 'sol'
set :application, "sol-api"
set :stage, "production"

set :repo_url, "https://github.com/caiena/sol-api.git"
