remove_file 'Gemfile'
run 'touch Gemfile'

add_source 'https://rubygems.org'

# Add some gems
gem 'rails'
gem 'pg'
gem 'sass-rails'
gem 'uglifier'
gem 'puma'
gem 'bourbon'
gem 'slim-rails'

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
end

gem_group :production, :staging do
  gem 'rails_12factor'
end

# set ruby version
version = `ruby --version`.match(/\d.\d.\d/)[0]
run %Q{ sed -i "2i ruby '#{version}'" Gemfile }

# Environment variables
run 'echo ".env" >> .gitignore'
run 'touch .env.sample'
run 'touch .env'

# Nice README
run 'rm README.rdoc'
run "echo '# #{@app_name.titleize}\n' > README.md"

run 'bundle:install'

generate 'rspec:install'

# SASS
sass = <<-SASS
@import 'bourbon'
SASS

# TODO:
# update application.rb
# selenium
# create staging.rb

remove_file 'app/assets/stylesheets/application.css'
create_file 'app/assets/stylesheets/application.css.sass', sass

# sass directories
sass_paths = %W{base components helpers ie layout pages themes vendor}

sass_paths.each do |path|
  file = "#{path}/#{path}"

  run "mkdir app/assets/stylesheets/#{path}"
  run "touch app/assets/stylesheets/#{file}.sass"
  run %Q{ echo "@import '#{file}'" >> app/assets/stylesheets/application.css.sass }
end

run 'mkdir spec/support'

# factory girl
copy_file File.expand_path('../spec/support/factory_girl.rb', __FILE__), 'spec/support/factory_girl.rb'

# database cleaner
copy_file File.expand_path('../spec/support/database_cleaner.rb', __FILE__), 'spec/support/database_cleaner.rb'

# rspec
rspec = <<-RSPEC
require 'pry'

# Require support directory
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
RSPEC

prepend_to_file 'spec/spec_helper.rb', rspec


# letter opener
insert_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do <<-OPENER
  config.action_mailer.delivery_method = :letter_opener
OPENER
end

# staging environment
run 'cp config/environments/production.rb config/environments/staging.rb'
gsub_file 'config/environments/staging.rb', /:debug/, ':warn'

capitalized = @app_name.upcase

staging = <<-YML

staging:
  <<: *default
  database: #{@app_name}_staging
  username: <%= ENV['#{capitalized}_DATABASE_USERNAME'] %>
  password: <%= ENV['#{capitalized}_DATABASE_PASSWORD'] %>

YML

append_to_file 'config/database.yml', staging
run 'cp config/database.yml config/database.yml.sample'
append_to_file '.gitignore', 'config/database.yml'

rake 'db:setup'
rake 'db:test:prepar'

git :init
git add: '.'
git commit: '-a -m initial commit'
git checkout: '-b develop'

