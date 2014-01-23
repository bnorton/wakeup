class Hat
  def self.sixtwo_s(numeric)
    numeric = numeric.abs
    s = numeric == 0 ? '0' : ''

    while numeric.send(:>, 0)
      s << SIXTYTWO[numeric.modulo(62)]
      numeric /= 62
    end
    s.reverse
  end

  def self.sixtwo_i(string)
    s = string.reverse.split('')

    total = 0
    s.each_with_index do |char, index|
      total += SIXTYTWO.index(char)*(62**index)
    end
    total
  end

  def self.short
    sixtwo_s(rand(RANGE_10))
  end

  def self.long
    sixtwo_s(rand(RANGE_24))
  end
end

Hat::SIXTYTWO = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
Hat::RANGE_10 = (13_537_086_546_263_552..839_299_365_868_340_223) # 100000000 to ZZZZZZZZZZ in base 62
Hat::RANGE_24 = (167_883_826_163_764_944_817_996_215_305_490_271_305_728..10_408_797_222_153_426_578_715_765_348_940_396_820_955_135) # 100000000000000000000000 to ZZZZZZZZZZZZZZZZZZZZZZZZ in base 62
