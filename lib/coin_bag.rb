class CoinBag
  attr_accessor :coins
  attr_accessor :total
  attr_accessor :count

  def initialize
    @coins = Hash.new(0)
    @count = 0
    @total = 0
  end

  # works like a dictionary, keeps track of total value and # of coins
  def []=(k, v)
    @count = @count - @coins[k] + v
    @total = (@total - k * @coins[k]) + (k * v)
    @coins[k] = v
  end

  def [](k)
    @coins[k]
  end
end
