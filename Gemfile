source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Defaults
ruby '2.4.1'
gem 'rails', '~> 5.1.5'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

# Third-party
gem 'devise'
gem 'exception_notification'
gem 'font-awesome-sass'
gem 'haml-rails'
gem 'pg', '~> 0.18'
gem 'bootstrap', '~> 4.0.0'
gem 'stripe'
gem 'webpacker', '~> 3.3'
gem 'figaro'
gem 'twilio-ruby', '~> 5.7.1'
gem 'cancancan', '~> 2.0'
gem 'phony_rails'
gem 'kaminari'
gem 'pg_search'
gem 'sidekiq'
gem 'newrelic_rpm'
gem 'bootsnap', require: false
gem 'stripe'
# gem 'stripe_event'
gem 'attr_encrypted'
gem "sentry-raven"
gem 'sendgrid-ruby'
gem 'gibbon'
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'

group :development do
  gem 'better_errors'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'html2haml'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'spring-commands-rspec'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'pry-rails'
end
group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end
group :test do
  gem 'database_cleaner'
  gem 'launchy'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]