source 'http://rubygems.org'
source 'http://gems.github.com' 

gem 'rails', '3.0.9'
gem 'jquery-rails'
gem 'capistrano', group: :development
gem 'haml'
gem 'will_paginate', '>=3.0.pre2'
gem "state_machine", '>=0.9.4'
gem 'authlogic'
gem "activemerchant"
gem "money"
gem "recaptcha", require: "recaptcha/rails"
gem "tabs_on_rails", ">=1.3.1"
gem "bartt-ssl_requirement", require: 'ssl_requirement'
gem "jammit"
gem 'spectator-validates_email', require: 'validates_email'

# Image processing. Currently there is an issue with Ruby ReadLine so we use a custom ImageScience.
gem 'carrierwave'
gem 'image_science', git: "git://github.com/asynchrony/image_science.git"

gem 'gibbon', group: :production

# Caching
gem 'redis'
gem 'redis-store', '>=1.0.0.beta4'

# Background jobs
gem 'stalker'
gem 'daemon-spawn'
gem "whenever"

# Database
gem 'sqlite3-ruby', require: 'sqlite3', group: [:development, :test]
gem "mysql2", "~> 0.2.7", group: [:production, :staging]

# Testing and monitoring
gem "factory_girl_rails", group: [:test, :development]
gem "timecop", group: :test
gem "newrelic_rpm", ">= 3.1.0"
gem 'hoptoad_notifier'