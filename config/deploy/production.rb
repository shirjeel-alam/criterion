# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

set :stage, :production
set :branch, 'master'

server '198.211.100.110', user: fetch(:user), roles: %w{web app db}, primary: true
set :deploy_to, "/home/#{fetch(:user)}/rails_apps/#{fetch(:application)}"
set :rails_env, :production