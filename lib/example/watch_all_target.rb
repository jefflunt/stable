# lib/example/watch_all_target.rb
class WatchAllTarget
  def self.a_class_method
    "I am a class method."
  end

  def an_instance_method
    "I am an instance method."
  end

  def another_instance_method
    "I am another instance method."
  end

  def an_excluded_method
    "I should not be watched."
  end
end
