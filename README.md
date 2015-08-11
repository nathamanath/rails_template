# Rails template

A rails template to save time configuring rails at the start of every project.

## What it does:

* Base sass file structure based on http://www.sitepoint.com/architecture-sass-project/
* RSpec and capybara setup with selenium, factory girl and database cleaner
* Remove un-needed files (./test)
* Set up dot env gem for development
* Make database.yml portable using environment variables
* Set up letter opener gem in development
* Get rid of jQuery, ujs, and turbo links
* Slim templating,
* layout/application.html.slim based on html5 bp
* Setup a staging environment
* Setup generators in application.rb
* Setup database
* Init git repo, handle initial commit, setup develop branch
* Markdown readme
* Static pages controller
* A smoke test
* Modernizr gem in development (make a custom build for production)
* Pick a database (pg, mysql, sqlite)
* Google analytics setup


## Development

### TODO:

* nicer management of Gemfile
* rake task to update vendored assets
* should have tests for all templated features
* base sass mixins... center, media etc
* some rails helpers... form validation errors, flash notificatins
