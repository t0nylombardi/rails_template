# frozen_string_literal: true

# Rails 7 template
# Author: t0nylombardi
# # (c) Copyright 2023
#
# https://github.com/t0nylombardi/rails-template
#
# v1.0.0
#
# Intro: A Rails template to set up your Rails project with
# Docker, Rspec, Devise, and  Tailwind.
#
# Installation:
# $ rails new myapp -d <postgresql, mysql, sqlite3> -m https://github.com/t0nylombardi/rails-template/default.rb
#
# Usage:
# To run the app: `docker-compose up`
# To go into shell: 'docker-compose run app bash'

def source_paths
  [__dir__]
end

git :init
git add: '.'
git commit: %( -m 'Initial commit' )

def add_docker
  copy_file 'Dockerfile'
  copy_file 'docker-compose.yml'

  directory 'script', force: true

  inside('script') do
    run 'chmod +x wait-for-tcp.sh'
    run 'chmod +x docker-dev-start-web.sh'
  end

  # Update config/database.yml development and test configs
  gsub_file 'config/database.yml', /^development:\n  <<: \*default/, <<-CODE
  development:
    <<: *default
    username: postgres
    password: postgres
    host: db
  CODE

  gsub_file 'config/database.yml', /^test:\n  <<: \*default/, <<-CODE
  test:
    <<: *default
    username: postgres
    password: postgres
    host: db
  CODE

  git add: '.'
  git commit: '-a -m \'Add Docker config to app\''
end

def add_gems
  gem 'devise', '~> 4.8', '>= 4.8.1'
  gem 'friendly_id', '~> 5.4', '>= 5.4.2'
  gem 'cssbundling-rails'
  gem 'name_of_person'
  gem 'sidekiq', '~> 6.5', '>= 6.5.4'
  gem 'stripe'

  gem_group :development, :test do
    gem 'pry'
    gem 'pry-stack_explorer'
    gem 'rspec-rails'
    gem 'factory_bot_rails'
    gem 'faker'
  end
end

def add_tailwind
  rails_command 'css:install:tailwind'
  # remove tailwind config that gets installed and swap for custom config
  remove_file 'tailwind.config.js'
end

def add_storage_and_rich_text
  rails_command 'active_storage:install'
  rails_command 'action_text:install'
end

def add_users
  # Install Devise
  generate 'devise:install'

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
              env: 'development'

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, 'User', 'first_name', 'last_name', 'admin:boolean'

  # set admin boolean to false by default
  in_root do
    migration = Dir.glob('db/migrate/*').max_by { |f| File.mtime(f) }
    gsub_file migration, /:admin/, ':admin, default: false'
  end

  # name_of_person gem
  append_to_file('app/models/user.rb', "\nhas_person_name\n", after: 'class User < ApplicationRecord')
end

def copy_templates
  directory 'app', force: true
  directory 'lib', force: true
end

def add_sidekiq
  environment 'config.active_job.queue_adapter = :sidekiq'

  insert_into_file 'config/routes.rb',
                   "require 'sidekiq/web'\n\n",
                   before: 'Rails.application.routes.draw do'

  content = <<-RUBY
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  RUBY
  insert_into_file 'config/routes.rb', "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def add_friendly_id
  generate 'friendly_id'
end

def add_tailwind_plugins
  run 'yarn add -D @tailwindcss/typography @tailwindcss/forms @tailwindcss/aspect-ratio @tailwindcss/line-clamp'

  copy_file 'tailwind.config.js'
end

def add_rspec
  generate 'rspec:install'

  file 'spec/support/factory_bot.rb', <<-CODE
  RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
  end
  CODE

  file 'spec/support/chrome.rb', <<-CODE
  RSpec.configure do |config|
    config.before(:each, type: :system) do
      if ENV["SHOW_BROWSER"] == "true"
        driven_by :selenium_chrome
      else
        driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
      end
    end
  end
  CODE
  file 'spec/factories.rb'

  content = <<-RUBY
  require_relative 'support/factory_bot'
  require_relative 'support/chrome'
  RUBY

  insert_into_file 'spec/rails_helper.rb', "#{content}\n", after: "require 'rspec/rails'\n"
end

# Main setup
source_paths

add_gems

after_bundle do
  add_docker
  add_rspec
  add_tailwind
  add_tailwind_plugins
  add_storage_and_rich_text
  add_users
  add_sidekiq
  copy_templates
  add_friendly_id

  git :init
  git add: '.'
  git commit: %( -m 'Final setup' )

  say
  say 'Kickoff app successfully created! 👍', :green
  say
  say 'Switch to your app by running:'
  say "$ cd #{app_name}", :yellow
  say
  say 'Then run:'
  say '$ ./bin/dev', :green
end
