set :application, 'criterion'
set :user, 'root'
set :repo_url, 'git@bitbucket.org:shirjeelalam/criterion.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :ssh_options, {
  forward_agent: true
}

set :delayed_job_bin_path, 'script'

namespace :deploy do
  after :finishing, 'deploy:cleanup'
end

namespace :delayed_job do
  desc 'Restart delayed_job'
  task :restart do
  	on roles(:app) do
	    execute "cd #{current_path}; RAILS_ENV=#{fetch(:rails_env).to_s} script/delayed_job stop; RAILS_ENV=#{fetch(:rails_env).to_s} script/delayed_job start"
	  end
  end
end
