=begin

In development mode, rails is very aggressive about unloading and reloading
classes as needed. Unfortunately, for crabgrass page types, rails always gets
it wrong. To get around this, we create static proxy representation of the
classes of each page type and load the actually class only when we have to.

=end

class PageClassProxy

  attr_accessor :controller
  attr_accessor :model
  attr_accessor :icon
  attr_accessor :class_display_name
  attr_accessor :class_description
  attr_accessor :class_group
  attr_accessor :class_name

  def initialize(page_class_name)
    self.class_name = page_class_name
    %w[controller model icon class_display_name class_description class_group].each do |attri|
      self.send(attri+'=',actual_class.send(attri))
    end
  end

  def actual_class
    Tool.const_get(self.class_name)
  end

  def create(hash)
    actual_class.create(hash)
  end

end