source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'execjs'
gem 'therubyracer'

gem 'mysql2'
gem 'faker'

gem 'activeadmin'
gem 'sass-rails'
gem 'meta_search'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

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