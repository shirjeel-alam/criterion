# config valid only for Capistrano 3.1
lock '3.2.1'

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

set :assets_prefix, "criterion/assets"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# namespace :deploy do
#   desc "Make symlink for database yaml."
#   task :db_symlink do
#     run "ln -snf #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
#   end

#   desc "Setup the database."
#   task :db_setup, roles: :app do
#     run [
#       "cd #{current_path}",
#       "bundle exec rake db:setup RAILS_ENV=#{rails_env}"
#     ].join(" && ")
#   end

#   # Passenger tasks
#   task :start do ; end
#   task :stop do ; end

#   desc "Restart Application"
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

# desc "tail log files"
# task :tail, :roles => :app do
#   run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
#     puts "#{channel[:host]}: #{data}"
#     break if stream == :err
#   end
# end
 
# namespace :assets do
#   desc "Precompile assets locally and then rsync to app servers"
#   task :precompile, :only => { :primary => true } do
#     run_locally "bundle exec rake assets:precompile;"
#     servers = find_servers :roles => [:app], :except => { :no_release => true }
#     servers.each do |server|
#       run_locally "rsync -av ./public/assets/ #{user}@#{server}:#{current_path}/public/assets/;"
#     end
#     run_locally "rm -rf public/assets"
#   end
# end

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Restarts Phusion Passenger
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  
  after :finishing, 'deploy:cleanup'
  after :publishing, :restart
  after :publishing, 'deploy:restart'
end