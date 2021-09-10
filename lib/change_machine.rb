require_relative './coin_bag'

class ChangeMachine
  attr_accessor :denominations

  def initialize(denominations = [])
    self.denominations = denominations
  end

  # returns change for amount but ensures we receive a minimum number of coins
  def change(amount, min_count = 0)
    bag = _change(amount)
    return bag if min_count == 0 # not strictly necessary, but cleaner to read

    # max number of the smallest denomination coin we could return
    (max_possible, remainder) = amount.divmod(denominations.last)
    max_possible = max_possible + 1 if remainder > 0

    if max_possible < min_count
      raise "No way to satisfy minimum of #{min_count} coins for #{amount}¢"
    end

    # distribute the largest available coin(s) into smaller coins
    # until we hit the minimum count required
    denominations.each_with_index do |d, i|
      while bag.count < min_count && bag[d] > 0
        bag[d] = bag[d] - 1
        _change(d, i+1).coins.each do |k,v|
          bag[k] = bag[k] + v
        end
      end
    end

    bag
  end

  def denominations=(denominations)
    @denominations = denominations.sort.uniq.reverse
  end

  private

  # amount is whole number in cents
  # denominations_idx is an index into the denominations array we should start from
  def _change(amount, denominations_idx = 0)
    raise "Cannot make change from a negative amount" if amount < 0
    raise "No denominations available" if denominations.empty?

    CoinBag.new.tap do |results|
      denominations[denominations_idx..-1].each do |d|
        coins, amount = amount.divmod(d)
        results[d] = coins
      end

      # if we still owe some change (i.e., we don't have a 1-cent denomination)
      # then we return an extra coin of the lowest denomination available
      results[denominations.last] = results[denominations.last] + 1 if amount > 0
    end
  end

end
