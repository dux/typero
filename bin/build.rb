require_relative '../lib/typero'
require 'sequel'

Sequel.extension :inflector

list = Dir["lib/typero/type/*.rb"].map do |el|
  el.split('/').last.split('.').first
end

types = []

for el in list
  klass = Typero::Type.load el
  types.push '#### "%s" type - [%s](https://github.com/dux/typero/blob/master/lib/typero/type/%s.rb)' % [el, klass, el]

  types.push ''

  model  = klass.new nil
  errors = klass.instance_methods(false).map(&:to_s).select { |it| it.include?('_error') }

  if errors.first
    types.push 'errors' % el

    for error in errors
      types.push '* %s - %s' % [error, model.send(error)]
    end

    block = errors.map { |it| '%s: "%s"' % [it, model.send(error)] }.join(', ')

    types.push "```\n  attributes do\n    #{el} :field, #{block}\n  end\n```"
  end

  types.push ''
  types.push ''
end

template = File.read 'README.md.tpl'
template.sub!('{{types}}', types.join($/))

File.write 'README.md', template

puts template