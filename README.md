# Rails template

A rails template to save time configuring rails at the start of every project.

## What it does:

* Base sass file structure based on http://www.sitepoint.com/architecture-sass-project/
* RSpec and capybara setup with selenium, factory girl and database cleaner
* Remove un-needed files (./test)
* Set up dot env gem for development
* Set up letter opener gem in development
* Get rid of jQuery, ujs, and turbo links
* Slim templating
* Setup a staging environment
* Setup generators in application.rb
* Setup database
* Init git repo
* Markdown readme
* Static pages controller
* A smoke test
* Modernizr gem in development (make a custom build for production)

## Development

### TODO:

* nicer management of Gemfile
* pick a database. Currently postgres only
* rake task to update vendored assets

