set :application, 'criterion'
set :user, 'root'
set :repo_url, 'git@bitbucket.org:shirjeelalam/criterion.git'
set :scm, :git
set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :ssh_options, {
  forward_agent: true
}

## rbenv
set :rbenv_ruby, '2.3.0'

## puma
set :puma_threads, [4, 16]
set :puma_workers, 1
set :puma_bind, "unix:///tmp/puma.sock"
set :puma_state, "#{shared_path}/pids/puma.state"
set :puma_pid, "#{shared_path}/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log, "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after :finishing, :cleanup
  after :finishing, :restart
end
