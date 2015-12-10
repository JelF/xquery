# XQuery
XQuery is designed to replace boring method call chains and allow to easier
convert it in a builder classes
## Usage of `XQuery` function
`Xquery` is a shortcat to `Xquery::Generic.with`

```
r = XQuery(''.html_safe) do |q|
  # similar to tap
  q << 'bla bla bla'
  q << 'bla bla bla'
  # using truncate
  q.truncate(15)
  # real content (q.send(:query)) mutated
  q << '!'
end
r # => "bla bla blab...!"
```
## Usage of `XQuery::Abstract`
I designed this gem to help me with `ActiveRecord` Queries, so i inherited
`XQuery::Abstract` and used it's powers. It provides the following features
### `wrap_method` and `wrap_methods`
when you call each of this methods they became automatically wrapped
(`XQuery::Abstract` basically wraps all methods query `#respond_to?`)
It means, that there are instance methods with same name defined and will
change a `#query` to their call result.
```
self.query = query.foo(x)
# is basically the same as
foo(x)
# when `wrap_method :foo` called
```

You can also specify new name using `wrap_method :foo, as: :bar` syntax
### `q` object
`q` is a proxy object which holds all of wrapped methods,
but not methods you defined inside your class.
E.g. i have defined `wrap_method(:foo)`, but also delegated `#foo` to some
another object. If i call `q.foo`, i will get wrapped method.
Note, that if you redefine `#__foo` method, q.foo will call it instead of
normal work.
You can add additional methods to `q` using something like `alias_on_q :foo`.
I used it with `kaminary` and it was useful
```
def page=(x)
  apply { |query| query.page(x) }
end
alias_on_q :page=

def page
  query.current_page
end
alias_on_q :page
```

### `query_superclass`
You should specify `query_superclass` class_attribute to inherit
`XQuery::Abstract`. Whenever `query.is_a?(query_superclass)` evaluate to false,
you will get `XQuery::QuerySuperclassChanged` exception.
It can save you much time when your class misconfigured.
E.g. you are using `select!` and it returns `nil`, because why not?

### `#apply` method
`#apply` does exact what it source tells
```
# yields query inside block
# @param block [#to_proc]
# @return [XQuery::Abstract] self
def apply(&block)
  self.query = block.call(query)
  self
end
```
It is usefull to merge different queries.

### `with` class method
You can get XQuery functionality even you have not defined a specific class
(You are still have to inherit XQuery::Abstract to use it)
You can see it in this document when i described `XQuery` function.
Note, that it yields a class instance, not `q` object.
It accepts any arguments, they will be passed to a constructor (except block)
If you want only to call one function on an instance (e.g. `#apply`),
you should prefer `execute` alias
