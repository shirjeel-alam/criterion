# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/bundler'
require 'capistrano/rails'
require 'capistrano/passenger'
require 'capistrano/clockwork'
require 'capistrano/rails/console'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }