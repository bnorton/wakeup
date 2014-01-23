require 'yaml'
require 'active_support/core_ext/hash'

##
# Read the given yaml file name for the config found in the current
# Rails environment falling back to the development env and give the config
# back with symbolized keys.
#
def read_yaml(name, env=nil)
  env ||= defined?(Rails) ? Rails.env : ENV['RAILS_ENV']

  name = name + '.yml' unless /\.yml$/ === name
  yaml = YAML.load(IO.read(File.expand_path("../../../config/#{name}", __FILE__)))
  config = yaml[env.to_s]
  if defined?(Rails)
    Rails.logger.warn("Defaulting to the development environment for config #{name}") unless config.present?
    Rails.logger.warn("Your config file didn't appear to have an #{env} key or a 'development' key") unless config.present? || yaml['development'].present?
  end

  (config || yaml['development']).symbolize_keys
rescue => e
  raise StandardError.new("Failed to load config #{name} in the #{env} environment. \nCheck the logs... hint: #{e.message}")
end
