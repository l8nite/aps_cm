require_relative '../lib/change_machine'

describe ChangeMachine do
  let (:denominations) { [1,5,10,25,50,100] }
  let (:machine) { ChangeMachine.new(denominations) }

  describe '#initialize' do
    let (:machine) { ChangeMachine.new }

    it 'sets the denominations to an empty list by default' do
      expect(machine.denominations).to be_empty
    end
  end

  describe '#denominations=' do
    it 'only stores unique denominations' do
      machine.denominations = [1, 1]
      expect(machine.denominations).to eq([1])
    end

    it 'sorts denominations by size (descending)' do
      machine.denominations = [10, 1, 50, 5, 25]
      expect(machine.denominations).to eq([50, 25, 10, 5, 1])
    end
  end

  describe '#change' do
    it 'raises an error if asked to make change for a negative amount' do
      expect { machine.change(-1) }.to raise_error("Cannot make change from a negative amount")
    end

    it 'raises an error if the denominations list is empty' do
      machine.denominations = []
      expect { machine.change(100) }.to raise_error("No denominations available")
    end

    it 'returns all denominations in the result set' do
      expected = Hash[machine.denominations.collect { |d| [d, 0] }]
      expect(machine.change(0).coins).to eq(expected)
    end

    it 'calculates single-coin results correctly' do
      expected = Hash[machine.denominations.collect { |d| [d, 0] }]
      machine.denominations.each do |denomination|
        expected[denomination] = expected[denomination] + 1
        expect(machine.change(denomination).coins).to eq(expected)
        expected[denomination] = 0
      end
    end

    it 'calculates multiple-coin results correctly' do
      expected = Hash[machine.denominations.collect { |denomination| [denomination, 0] }]
      expected[1] = 1 # we'll add 1 cent to each denomination
      machine.denominations.each do |denomination|
        expected[denomination] = expected[denomination] + 1
        expect(machine.change(denomination + 1).coins).to eq(expected)
        expected[denomination] = 0
      end
    end

    it 'returns an extra of the smallest denomination when there is a remainder' do
      machine.denominations = [5, 10, 25]
      change = machine.change(6)
      expect(change.coins).to eq({5 => 2, 10 => 0, 25 => 0})
      expect(change.count).to eq(2)
      expect(change.total).to eq(10)
    end

    describe 'with a maximum possible coins less than the minimum' do
      it 'raises an error with an even divisor' do
        machine.denominations = [3]
        # if we make change for $0.03 using 3-cent coins, the maximum possible is 1 coin
        expect { machine.change(3, 2) }.to raise_error(/No way to satisfy minimum/)
      end

      it 'raises an error with an odd divisor' do
        machine.denominations = [2]
        # if we make change for $0.03 using 2-cent coins, the maximum possible is 2 coins
        expect { machine.change(3, 3) }.to raise_error(/No way to satisfy minimum/)
      end
    end

    it 'works' do
      expected = [
        { range: (0..3),   coins: { 50 => 1, 25 => 1, 10 => 0, 5 => 0,  1 => 1  } },
        { range: (4..4),   coins: { 50 => 0, 25 => 3, 10 => 0, 5 => 0,  1 => 1  } },
        { range: (5..6),   coins: { 50 => 0, 25 => 2, 10 => 2, 5 => 1,  1 => 1  } },
        { range: (12..12), coins: { 50 => 0, 25 => 0, 10 => 4, 5 => 7,  1 => 1  } },
        { range: (73..76), coins: { 50 => 0, 25 => 0, 10 => 0, 5 => 0,  1 => 76 } },
      ]

      expected.each_with_index do |e, i|
        e[:range].each do |min|
          change = machine.change(76, min)
          expect(change.coins).to include(e[:coins]), "Expected $0.76 with #{min} coins minimum to be: #{e[:coins]}"
        end
      end
    end
  end
end
