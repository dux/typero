# require 'hash_wia'

# base libs
require_relative 'typero/typero'
require_relative 'typero/schema'
require_relative 'typero/define'
require_relative 'typero/type/type'

# checker types
Dir['%s/typero/type/types/*.rb' % __dir__].each do |file|
  require file
end

# load Sequel adapter is Sequel is available
require_relative './adapters/sequel' if defined?(Sequel)
