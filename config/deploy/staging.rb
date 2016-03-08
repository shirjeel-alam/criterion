set :stage, :production
set :branch, 'develop'

server '198.199.83.180', user: fetch(:user), roles: %w{web app db}, primary: true
set :deploy_to, "/home/#{fetch(:user)}/rails_apps/#{fetch(:application)}"
set :rails_env, :production
