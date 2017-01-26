require 'active_support'

# XQuery is designed to replace boring method call chains and allow to easier
# convert it in a builder classes
# see [README.md] for more information
module XQuery
  autoload :Abstract, 'xquery/abstract'
  autoload :QuerySuperclassChanged, 'xquery/errors'
  autoload :Generic, 'xquery/generic'
  autoload :QueryProxy, 'xquery/query_proxy'
  autoload :VERSION, 'xquery/version'
end

# Allows you to do all query magic on a generic object
# @param model [Object] any object
# @yield block where instance will be yielded
def XQuery(model)
  XQuery::Generic.with(model) { |instance| yield(instance) }
end
