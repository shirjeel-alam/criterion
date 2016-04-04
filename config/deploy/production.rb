set :stage, :production
set :branch, 'master'

server '198.211.100.110', user: fetch(:user), roles: %w{web app db}, primary: true
set :deploy_to, "/home/#{fetch(:user)}/rails_apps/#{fetch(:application)}"
set :rails_env, :production

set :puma_threads, [4, 16]
set :puma_workers, 1
set :puma_bind, "unix://#{shared_path}/sockets/puma.sock"
set :puma_state, "#{shared_path}/pids/puma.state"
set :puma_pid, "#{shared_path}/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log, "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
