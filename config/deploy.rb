set :application, 'criterion'
set :user, 'root'
set :repo_url, 'git@bitbucket.org:shirjeelalam/criterion.git'
set :scm, :git
set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :ssh_options, {
  forward_agent: true
}

set :rbenv_ruby, '2.3.0'

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
