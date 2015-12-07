DATABASES = {
  mysql: {
    gem: 'mysql2',
    adapter: 'mysql2'
  },
  pg: {
    gem: 'pg',
    adapter: 'postgresql'
  },
  sqlite: {
    gem: 'sqlite3',
    adapter: 'sqlite3'
  }
}

APP_TITLE = @app_name.titleize


# Prompt user to select db
db = nil
db_user = nil
db_pass = nil

while !DATABASES.map{ |k, v| k }.include?(db) do
  db = ask("Which database? type 'mysql', 'sqlite', or 'pg'?").to_sym
end

if db != :sqlite
  db_user = ask("Database username:")
  db_pass = ask("Database password:")
end

# gems
remove_file 'Gemfile'
run 'touch Gemfile'

add_source 'https://rubygems.org'

# Add some gems
gem 'rails'
gem DATABASES[db][:gem]
gem 'sass-rails'
gem 'uglifier'
gem 'puma'
gem 'bourbon'
gem 'slim-rails'
gem 'therubyracer'

gem_group :development, :test do
  gem 'byebug'
  gem 'rspec-rails'
  gem 'web-console'
  gem 'spring'
  gem 'pry'
  gem 'letter_opener'
  gem 'better_errors'
  gem 'spring-commands-rspec'
  gem 'awesome_print'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'dotenv-rails'
  gem 'modernizr-rails'
end

gem_group :production, :staging do
  gem 'rails_12factor'
end

# set ruby version
version = `ruby --version`.match(/\d.\d.\d/)[0]
run %Q{ sed -i "2i ruby '#{version}'" Gemfile }

# Environment variables
run 'echo ".env" >> .gitignore'
run 'touch .env'

database_name = (db == :sqlite)? 'db/development.sqlite3' : "#{@app_name.underscore}_development"

env = <<-ENV
DATABASE_NAME=#{database_name}_development
DATABASE_USERNAME=#{db_user}
DATABASE_PASSWORD=#{db_pass}
ANALYTICS_TRACKING_CODE=
ENV

append_to_file '.env', env

run 'cp .env .env.sample'


# Use environment variables to make database.yml portable
remove_file 'config/database.yml'
copy_file File.expand_path('../config/database.yml', __FILE__), 'config/database.yml'
gsub_file 'config/database.yml', 'ADAPTER', DATABASES[db][:adapter]

gsub_file 'config/database.yml', /.*unicode\n/, '' unless db == :pg


# Tidy up unwanted files
run 'rm -r test'


# Nice README
run 'rm README.rdoc'
run "echo '# #{APP_TITLE}\n\n' > README.md"


# Layout
layout_dir = 'app/views/layouts/'
layout_path = "#{layout_dir}application.html.slim"

remove_file "#{layout_dir}application.html.erb"

directory File.expand_path("../#{layout_dir}", __FILE__), layout_dir
gsub_file layout_path, /DEFAULT_TITLE/, APP_TITLE


# SASS
remove_file 'app/assets/stylesheets/application.css'
directory File.expand_path('../app/assets/stylesheets', __FILE__), 'app/assets/stylesheets'
directory File.expand_path('../vendor', __FILE__), 'vendor'


# JS
gsub_file 'app/assets/javascripts/application.js', /^.*jquery.*\n/, ''


# staging environment
run 'cp config/environments/production.rb config/environments/staging.rb'
gsub_file 'config/environments/staging.rb', /:debug/, ':warn'

secrets = <<-YML

staging:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
YML

append_to_file 'config/secrets.yml', secrets


# configure generators
application do <<-RUBY
  config.sass_preferred_syntax = :sass

  config.generators do |g|
    g.test_framework :rspec, fixtures: true,
      view_specs: false,
      helper_specs: false,
      routing_specs: false,
      controller_specs: false,
      request_specs: false,
      model_specs: true

    g.fixture_replacement :factory_girl, dir: 'spec/factories'

    g.stylesheets = false
    g.javascripts = false
    g.helpers = false
  end
RUBY
end


# Everything dependent on bundle
after_bundle do
  # Spring broke rspec generator?!?!?!
  run 'spring stop'


  # rspec
  generate 'rspec:install'

  rspec = <<-RSPEC
  require 'pry'

  # Require support directory
  Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
  RSPEC

  prepend_to_file 'spec/spec_helper.rb', rspec

  insert_into_file 'spec/rails_helper.rb', after: "require 'rspec/rails'\n" do <<-RUBY
  require "capybara/rails"
  require "capybara/rspec"

  Capybara.javascript_driver = :selenium
  RUBY
  end
  run 'mkdir spec/support'


  # factory girl
  copy_file File.expand_path('../spec/support/factory_girl.rb', __FILE__), 'spec/support/factory_girl.rb'


  # database cleaner
  copy_file File.expand_path('../spec/support/database_cleaner.rb', __FILE__), 'spec/support/database_cleaner.rb'


  # letter opener
  insert_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do <<-OPENER
    config.action_mailer.delivery_method = :letter_opener
  OPENER
  end

  # Database setup
  rake 'db:create'
  rake 'db:migrate'
  rake 'db:test:prepare'


  # Static controller
  generate 'controller static index'
  route "root 'static#index'"


  # Smoke test
  directory File.expand_path('../spec/features', __FILE__), 'spec/features'


  # Git
  run 'git init && git add . && git commit -m "initial commit" && git checkout -b develop'
end
