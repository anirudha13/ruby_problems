# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.require "about_extra_credit"

#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

MAX_SCORE=500

class DiceSet
  attr_reader :values
  
  def roll(rolls)
    @values = Array.new
    rolls.times do
      @values << 1 + Random.rand(6)  
    end
    @values
  end
end

class ScoreCalculator
  attr_reader :rolls
  attr_reader :times
  
  def initialize(rolls)
    if (!rolls.is_a?(Array)) 
      raise ArgumentError, "Score should be initialized with an Array symbolizing dice rolls."
    end
    @rolls = rolls
    @times = calculateTimes
  end
  
  def calculateTimes
    times = Hash.new(0)
    @rolls.each do |r|
      times[r] += 1
    end
    times
  end
  
  def score
    @score = 0
    @score += calculate_triplets
    @score += calculate_singles
    @score
  end
  
  def calculate_triplets
    calc = 0
    @times.each_pair do |roll, times|
      if (times >= 3)
        if (roll == 1)
          calc += 1000
        else
          calc += 100 * roll
        end
      end
    end
    calc
  end
  
  def calculate_singles
    calc = 0
    @times.each_pair do |roll, times|
      if (roll == 1 && times % 3 != 0)
        calc += 100 * (times % 3)
      end
      if (roll == 5 && times % 3 != 0)
        calc += 50 * (times % 3)
      end
    end
    calc
  end
  
  def non_scoring_rolls
    non_scoring_rolls = 0
    [2,3,4,6].each do |roll|
      if (@times.has_key?(roll) && @times[roll] % 3 != 0)
        non_scoring_rolls += @times[roll]
      end
    end
    non_scoring_rolls
  end
  
end

class Player
  attr_reader :total_score
  attr_reader :name
  attr_reader :turns
  attr_reader :rolls
  attr_reader :idx 
  
  def initialize(idx)
    @idx = idx
    @name = "Player #{idx}"
    @turns = 5
    @rolls = 0
    @total_score = 0
  end
  
  def roll
    @rolls += 1
    diceset = DiceSet.new
    diceset.roll(5)
    puts "#{name} rolls: #{diceset.values.join(", ")}"
    calculator = ScoreCalculator.new(diceset.values)
    score = calculator.score
    @total_score += score
    puts "Score in this round: #{score}"
    puts "Total score: #{@total_score}"
    unused_rolls = calculator.non_scoring_rolls
    if (unused_rolls > 0)
      extra_score = doAdditionalRolls(unused_rolls)
      if (extra_score == 0)
        @total_score = 0
      end
      puts "Score in this round: #{extra_score}"
      puts "Total score: #{@total_score}"
    end
  end

  def doAdditionalRolls(rolls)
    print "Do you want to roll the non-scoring #{rolls} dice(s)?(y/n): "
    answer = gets.strip
    score = -1
    if (answer.eql?("y"))
      diceset = DiceSet.new
      diceset.roll(rolls)
      puts "#{name} rolls: #{diceset.values.join(", ")}"
      calculator = ScoreCalculator.new(diceset.values)
      score = calculator.score
    end
    score
  end

end

class Game
  attr_reader :players
  attr_reader :turns
  attr_reader :inFinalRound

  def initialize(numPlayers)
    @players = Array.new
    numPlayers.times do |idx|
      @players << Player.new(idx + 1)
    end
    @inFinalRound = false
    @turns = 0
  end

  def turn
    @turns += 1
    puts ""
    puts "Turn #{@turns}"
    puts "----------------"
    @players.each do |player|
      player.roll
      if (player.total_score >= MAX_SCORE)
        puts "#{player.name} reached #{MAX_SCORE} next round is Final round"
        @inFinalRound = true
      end
      puts
    end
  end

  def play
    while !@inFinalRound do
      turn
    end
    puts "Reached Final round after #{@turns} turn(s)!!"
    playFinalRound
  end

  def playFinalRound
      puts "Final round"
      puts "--------------"
      winner = nil
      @players.each do |player|
        player.roll
        if (winner.nil?)
          winner = player
          next
        end
        if (player.total_score > winner.total_score)
          winner = player
        end
      end
      puts
      puts "!!!!!! WE HAVE A WINNER !!!!!!"
      puts "#{winner.name} won with score of #{winner.total_score}"
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end
end

print "Enter number of players: "
numPlayers = gets.strip
game = Game.new(numPlayers.to_i)
game.play
