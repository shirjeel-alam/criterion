set :stage, :production
set :branch, 'master'

server '198.211.100.110', user: fetch(:user), roles: %w{web app db}, primary: true
set :deploy_to, "/home/#{fetch(:user)}/rails_apps/#{fetch(:application)}"
set :rails_env, :production
