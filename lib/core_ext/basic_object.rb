module BasicObjectInstanceMethods
  ##
  # Invoke a block if I am truthy
  #
  def tap_if
    yield(self) if self

    self
  end
end

BasicObject.send(:include, BasicObjectInstanceMethods)
