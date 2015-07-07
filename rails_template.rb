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

sass = <<-SASS
@import 'bourbon'

SASS

run 'echo ".env" >> .gitignore'

run "rm app/assets/stylesheets/application.css"
run "echo '#{sass} > app/assets/stylesheets/application.sass'"

run 'rm README.rdoc'
run "echo '# #{@app_name.titleize}\n' > README.md"

run 'bundle:install'

generate 'rspec:install'

rake 'db:setup'

git :init
git add: '.'
git commit: '-a -m initial commit'

