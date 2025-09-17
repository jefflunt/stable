# lib/example/class_methods.rb
module MyModule
  def self.do_something(val)
    "module did #{val}"
  end
end

class MyClass
  def self.do_something_else(val)
    "class did #{val}"
  end
end
