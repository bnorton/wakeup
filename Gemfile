source 'https://rubygems.org'
ruby '2.1.0'

gem 'rails'
gem 'pg'

gem 'puma'

gem 'sidekiq'

gem 'newrelic_rpm'

gem 'typhoeus'

group :development, :test do
  gem 'rspec-rails'
end

group :sidekiq do
  gem 'tilt'
  gem 'slim'
  gem 'sinatra', :require => nil
end

group :test do
  gem 'fuubar'
  gem 'mock_redis'
  gem 'factory_girl'
  gem 'webmock'
  gem 'timecop'
  gem 'connection_pool'
  gem 'shoulda-matchers', :require => nil
end

