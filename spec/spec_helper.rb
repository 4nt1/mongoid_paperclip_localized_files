require 'bundler/setup'
Bundler.setup

require 'mongoid'
require 'localized_files'

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
  I18n.enforce_available_locales = false
end