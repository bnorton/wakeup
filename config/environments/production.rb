Wakeup::Application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.serve_static_assets = false
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0'

  config.i18n.fallbacks = true

  config.log_level = :info
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
end
