require File.expand_path('../boot', __FILE__)

require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'

Bundler.require(:default, Rails.env)

module Wakeup
  class Application < Rails::Application
    config.time_zone = 'UTC'

    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :en
  end
end
