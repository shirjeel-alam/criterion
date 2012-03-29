source 'http://rubygems.org'

gem 'rails', '3.2.2'
gem 'therubyracer'

gem 'faker'
gem 'airbrake'
gem 'validates_timeliness'

gem 'activeadmin'
gem 'sass-rails'
gem 'meta_search'

gem 'jquery-rails'
gem 'best_in_place'
gem 'tinymce-rails', :git => 'git://github.com/spohlenz/tinymce-rails.git'
gem 'chosen-rails'

gem 'rufus-scheduler'
gem 'googlecharts'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# For heroku db:push and db:pull
# gem 'taps'
gem 'thin'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'uglifier'
end

group :development, :test do
  gem 'mysql2'

  # Pretty printed test output
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'pry-rails'
  gem 'turn', :require => false
end

group :production do
  gem 'heroku'
  gem 'pg'
end
