# require "bundler/capistrano"

# The application name is used to determine what repository to pull from, name databases and other nifty stuff.
set :application, 'criterion'

# Set the Rails Environment
set :rails_env, 'production'

# Server Settings. The port is optional, default to 22.
# server 'li69-232.members.linode.com', :web, :app, :db, primary: true
server '198.211.100.110', :web, :app, :db, primary: true

# User in the remote server. This is the user who's going to be used to deploy, and must have proper permissions.
set :user, 'root'

# Folder in the remote server where the revisions are going to be deployed.
set :deploy_to, "/home/#{user}/rails_apps/#{application}"

# The branch that's going to be checked out. Releases are going to be made everytime there's a new revision (+x commits ahead).
set :branch, 'master'

# Database Settings.
set :database_adapter,  'mysql2'
set :database_password, 'aXe@r4zeR'
set :database_username, user

# Use sudo when deploying the application.
# Dunno what's default but true is evil.
set :use_sudo, false

# Hack to allow Capistrano to prompt for password.
# Comment out if the deployer user needs a password for sudo.
# set :sudo_prompt, ""

# Choose the Source Control Management tool of your preference.
# (Don't. Really. Use git).
set :scm, :git

# Set the repository we're going to pull from.
set :repository,  'git@bitbucket.org:shirjeelalam/criterion.git'

# Setup the way you want the deploy to be done.
# I sincerely suggest using :remote_cache.
set :deploy_via, :remote_cache

# Pseudo Terminals.
# If you want Capistrano client password prompt to work this must be true.
default_run_options[:pty] = true

# Imagine you ask a friend to give you his car keys to drive it by yourself.
ssh_options[:forward_agent] = true

namespace :deploy do
  desc "Make symlink for database yaml."
  task :db_symlink do
    run "ln -snf #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end

  desc "Setup the database."
  task :db_setup, roles: :app do
    run [
      "cd #{current_path}",
      "bundle exec rake db:setup RAILS_ENV=#{rails_env}"
    ].join(" && ")
  end

  # Passenger tasks
  task :start do ; end
  task :stop do ; end

  desc "Restart Application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "tail log files"
task :tail, :roles => :app do
  run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

# namespace :deploy do
#  task :default do
#    update
#    assets.precompile
#    restart
#    cleanup
#    # etc
#  end
# end
 
namespace :assets do
  desc "Precompile assets locally and then rsync to app servers"
  task :precompile, :only => { :primary => true } do
    run_locally "bundle exec rake assets:precompile;"
    servers = find_servers :roles => [:app], :except => { :no_release => true }
    servers.each do |server|
      run_locally "rsync -av ./public/assets/ #{user}@#{server}:#{current_path}/public/assets/;"
    end
    run_locally "rm -rf public/assets"
  end
end


# Hooks
# before "deploy",            "deploy:db_symlink"
# before "deploy:migrations", "deploy:db_symlink"
# before "deploy:db_setup",   "deploy:db_symlink"

# after "deploy:update_code", "deploy:assets:precompile"
# after "deploy:finalize_update", "deploy:assets:symlink"

# after "deploy:finalize_update", "deploy:db_symlink"


set :keep_releases, 5
after "deploy:restart", "deploy:cleanup" 
after "deploy:update_code", "deploy:migrate"
