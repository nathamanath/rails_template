gem 'puma'
gem 'bourbon'
gem 'slim-rails'

gem_group :development, :test do
  gem 'byebug'
  gem 'rspec-rails'
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

run 'echo ".env" >> .gitignore'
run 'touch .env.sample'
run 'touch .env'


run 'rm README.rdoc'
run "echo '# #{@app_name.titleize}\n' > README.md"

run 'bundle:install'

generate 'rspec:install'

sass = <<-SASS
@import 'bourbon'
SASS

# update application.rb
# selenium
run "rm app/assets/stylesheets/application.css"
run %Q{ echo "#{sass}" > app/assets/stylesheets/application.css.sass }

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
girl = File.read File.expand_path('../spec/support/factory_girl.rb', __FILE__)
run "echo '#{girl}' > spec/support/factory_girl.rb"


# database cleaner
cleaner = File.read File.expand_path('../spec/support/database_cleaner.rb', __FILE__)
run "echo '#{cleaner}' > spec/support/database_cleaner.rb"


# rspec
rspec = <<-RSPEC
require 'pry'

# Require support directory
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
RSPEC

spec_helper_path = 'spec/spec_helper.rb'

content = File.read spec_helper_path

File.open spec_helper_path, 'w+' do |f|
  f.puts rspec
  f.puts content
end

# letter opener
opener = <<-OPENER
  config.action_mailer.delivery_method = :letter_opener
OPENER

run "sed -i '2i #{opener}' config/environments/development.rb"

rake 'db:setup'

git :init
git add: '.'
git commit: '-a -m initial commit'

