class RateManyPage < Page
    
  def initialize(*args)
    super(*args)
    self.data = Poll.new
  end
  
end
