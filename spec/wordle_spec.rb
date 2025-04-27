
require_relative '../source/wordle'
require_relative '../source/guess'

RSpec.describe Wordle do
  describe '#green_errors' do
    let(:date) { DateTime.now }
    let(:person) { 'Test Person' }
    let(:wordle_number) { '123' }

    def create_wordle_with_guesses(guess_patterns)
      data = guess_patterns.join("\n")
      Wordle.new(person, wordle_number, date, data)
    end

    it 'returns 0 when there is only one guess' do
      wordle = create_wordle_with_guesses(['⬜⬜🟩⬜⬜'])
      expect(wordle.green_errors).to eq(0)
    end

    it 'returns 0 when there are no guesses' do
      wordle = create_wordle_with_guesses([])
      expect(wordle.green_errors).to eq(0)
    end

    it 'counts one error when a green becomes non-green in next guess' do
      wordle = create_wordle_with_guesses([
        '⬜⬜🟩⬜⬜',
        '⬜⬜⬜⬜⬜'
      ])
      expect(wordle.green_errors).to eq(1)
    end

    it 'counts multiple errors when multiple greens become non-green' do
      wordle = create_wordle_with_guesses([
        '🟩🟩🟩⬜⬜',
        '⬜⬜🟩⬜⬜'
      ])
      expect(wordle.green_errors).to eq(2)
    end

    it 'accumulates errors across multiple guesses' do
      wordle = create_wordle_with_guesses([
        '🟩⬜🟩⬜⬜',  # Two greens
        '⬜⬜🟩⬜⬜',  # Lost one green (1 error)
        '⬜⬜⬜⬜⬜'   # Lost another green (1 more error)
      ])
      expect(wordle.green_errors).to eq(2)
    end

    it 'ignores when non-green becomes green' do
      wordle = create_wordle_with_guesses([
        '⬜⬜⬜⬜⬜',
        '🟩🟩🟩⬜⬜'
      ])
      expect(wordle.green_errors).to eq(0)
    end

    it 'handles mixed patterns correctly' do
      wordle = create_wordle_with_guesses([
        '🟩⬜🟩⬜🟩',  # Three greens
        '🟩⬜⬜🟩🟩',  # Lost one green, gained one (1 error)
        '🟩🟩⬜⬜🟩'   # Lost one green, gained one (1 error)
      ])
      expect(wordle.green_errors).to eq(2)
    end
  end
end
