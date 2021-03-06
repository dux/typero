require 'amazing_print'
require 'active_support/all'

require_relative '../lib/typero'

# basic config
RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # rspec -fd
  # config.formatter = :documentation # :progress, :html, :json, CustomFormatterClass
end
