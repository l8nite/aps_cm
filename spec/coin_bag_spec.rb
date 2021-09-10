require_relative '../lib/coin_bag'

describe CoinBag do
  let (:bag) { CoinBag.new }

  describe '#initialize' do
    it 'initializes count to 0' do
      expect(bag.count).to eq(0)
    end

    it 'initializes total to 0' do
      expect(bag.total).to eq(0)
    end

    it 'initializes coins to empty set' do
      expect(bag.coins).to be_empty
    end
  end

  describe '#[]=' do
    before :each do
      expect(bag[5]).to eq(0)
      expect(bag.count).to eq(0)
      expect(bag.total).to eq(0)
    end

    it 'sets the appropriate coin value' do
      bag[5] = 5
      expect(bag[5]).to eq(5)
    end

    it 'updates the count' do
      bag[5] = 5
      expect(bag.count).to eq(5)
    end

    it 'updates the total' do
      bag[5] = 5
      expect(bag.total).to eq(25)
    end
  end
end
