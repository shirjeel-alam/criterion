source 'http://rubygems.org'

gem 'rails'
gem 'execjs'
gem 'therubyracer'

gem 'mysql2'
gem 'faker'
gem 'airbrake'
gem 'validates_timeliness'

gem 'activeadmin'
gem 'meta_search'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
end

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
gem 'taps'

group :development, :test do
  # Pretty printed test output
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'turn', :require => false
  gem 'thin'
end

group :prouduction do
  gem 'heroku'
  gem 'pg'
end
