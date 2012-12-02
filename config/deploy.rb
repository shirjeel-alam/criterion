# require "bundler/capistrano"

# The application name is used to determine what repository to pull from, name databases and other nifty stuff.
set :application, 'criterion'

# Set the Rails Environment
set :rails_env, 'production'

# Server Settings. The port is optional, default to 22.
server 'li73-19.members.linode.com', :web, :app, :db, primary: true

# User in the remote server. This is the user who's going to be used to deploy, and must have proper permissions.
set :user, 'deploy'

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

# RVM Gemset
set :rvm_ruby_string, 'ruby-1.9.3-p327@criterion'

# Pseudo Terminals.
# If you want Capistrano client password prompt to work this must be true.
default_run_options[:pty] = true

# Imagine you ask a friend to give you his car keys to drive it by yourself.
ssh_options[:forward_agent] = true

namespace :deploy do
  desc "Create database yaml in shared path."
  task :db_configure do
    db_config = <<-EOF
      #{rails_env}:
        adapter:  #{database_adapter}
        database: #{application}_#{rails_env}
        pool: 25
        username: #{database_username}
        password: #{database_password}
    EOF

    run "mkdir -p #{shared_path}/config"
    put db_config, "#{shared_path}/config/database.yml"
  end

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

namespace :rvm do
  desc 'Trust rvmrc file'
  task :trust_rvmrc do
    run "rvm rvmrc trust #{current_release}"
  end
end

# Before hooks. You can define your own too!
before "deploy",            "deploy:db_symlink"
before "deploy:migrations", "deploy:db_symlink"
before "deploy:db_setup",   "deploy:db_symlink"

after "deploy", "deploy:cleanup"
after "deploy:update_code", "rvm:trust_rvmrc"