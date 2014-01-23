ENV['RAILS_ENV'] = 'test'
ENV['RUBYMINE']  = 'true' if (rubymine = /RubyMine/ === ENV['RUBYLIB'])

ENV['DBNAME'] = 'rubymine-test' if rubymine

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'timecop'

Dir[Rails.root.join('spec/{factories,support}/**/*.rb')].each {|f| require f }

WebMock.disable_net_connect!(:allow_localhost => true)

unless rubymine
  Rails.logger.info "\n[#{Time.now.localtime}] - Logging with level ERROR (4). see #{__FILE__}:#{__LINE__}"
  Sidekiq.logger.level = Rails.logger.level = 4
end

silence_warnings {
  Redis = MockRedis
}

RSpec.configure do |config|
  config.mock_with :rspec

  config.formatter = Fuubar unless rubymine

  config.infer_base_class_for_anonymous_controllers = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.use_transactional_fixtures = true

  config.include FactoryGirl::Syntax::Methods

  config.include Rails.application.routes.url_helpers, :url_helpers => true

  config.before :suite do
    Rails.application.eager_load!
  end

  config.before :each do
    Sidekiq.redis {|r| r.flushdb }
  end

  config.before(:each, :frozen => true) { Timecop.return }
  config.after(:each, :frozen => true) { Timecop.return }
end

Dir[Rails.root.join('db/migrate/*.rb')].each {|f| require f }

def safe(meth)
  send(meth)
rescue
  nil
end
