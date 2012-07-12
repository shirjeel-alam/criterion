source 'http://rubygems.org'

gem 'rails', '3.2.6'
gem 'therubyracer'

gem 'faker'
gem 'airbrake'
gem 'validates_timeliness'

gem 'activeadmin'
gem 'sass-rails'

gem 'jquery-rails'
gem 'best_in_place'
gem 'tinymce-rails'
gem 'chosen-rails'
gem 'fancybox-rails'

gem 'rufus-scheduler'
gem 'googlecharts'

gem 'thin'

gem 'hash_syntax'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# For heroku db:push and db:pull
gem 'taps'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'uglifier'
end

group :development, :test do
  gem 'mysql2'
  gem 'sqlite3'
  gem 'pry-rails'
  gem 'annotate', git: 'https://github.com/ctran/annotate_models.git'
end

group :development do
  # gem 'mailcatcher'
end

group :production do
  gem 'heroku'
  gem 'pg'
end
