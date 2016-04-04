set :stage, :production
set :branch, 'master'

server '139.59.241.117', user: fetch(:user), roles: %w{web app db}, primary: true
set :deploy_to, "/#{fetch(:user)}/rails_apps/#{fetch(:application)}"
set :rails_env, :production
