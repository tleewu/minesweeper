require 'yaml'
require 'byebug'

class Minesweeper
  attr_reader :board
  def initialize(board)
    @board = board
    @display = Array.new(board.size){Array.new(board.size)}
    @over = false
  end

  def play
    #until game over?
    #display board, then prompt player to move
    #then reveal a square/squares on @display
    until @over
      show

      row, col, mark = prompt
      if mark == "f"
        @display[row][col] = "F"

      elsif mark == "s"
        File.open("minesweeper_save.yml", "w") do |f|
          f.puts(self.to_yaml)
          f.close()
        end

        exit 0
      else
        reveal([row, col]) #just reveal on display
      end

      puts "Game Won!" if won?
    end
  end

  def show
    @display.each_with_index do |row, idx|
      print row.to_s + " " + idx.to_s + "\n"
    end
    (0..(board.size-1)).each {|num| print ("%3s" % num.to_s) + "  "}
    puts " "
  end

  def reveal(pos)
    square =  @board.grid[pos[0]][pos[1]]

    # if a bomb, game over
    if square == "*"

      @display[pos[0]][pos[1]] = "*"
      show
      puts "GAME OVER"
      sleep(5)
      @over = true

    # if a number, don't recurse
    elsif square != 0
      @display[pos[0]][pos[1]] = square.to_s

    # if 0 or blank case
    else
      #go through each adjacent square, calling with reveal()
      # if neighbors have NOT been revealed
      @display[pos[0]][pos[1]] = " "
      Board.neighbors(pos, board.size).each do |move|
        reveal(move) if @display[move[0]][move[1]].nil?
      end
    end
  end

  def won? #if every NON-bomb is revealed
    @display.each_with_index do |row, idx|
      row.each_with_index do |square, idx2|
        #return false if square is covered AND it is a number/empty space
#debugger
        return false if (square.nil? || square == 'F') && @board.grid[idx][idx2] != "*"
      end
    end

    @over = true
    return true
  end

  def prompt
    print "Pick a Row: "
    row = gets.chomp.to_i
    print "Pick a Col: "
    col = gets.chomp.to_i
    print "Pick a Mark: (f/r/s)"
    mark = gets.chomp.downcase

    return row, col, mark
  end

end #end Minesweeper class

class Board
  attr_reader :grid, :size, :mine_count

  def initialize(size = 9, mine_count = 10)
    @size = size
    @mine_count = mine_count
    @grid = Array.new(size) { Array.new(size) }

    #populate bombs
    mine_count.times {
      loop do
        num = rand(0..(size*size-1))
        row = num / size
        col = num % size
        if @grid[row][col].nil?
          @grid[row][col] = "*"
          break
        end
      end
    }

    #populate numbers
    @grid.each_with_index do |row, idx|
      row.each_with_index do |col, idx2|
        @grid[idx][idx2] = count_bomb([idx,idx2]) if @grid[idx][idx2] != "*"
      end
    end

  end

  def count_bomb (pos) #pos is NOT bomb
    count = 0

    Board.neighbors(pos, size).each do |move|
      count += 1 if @grid[move[0]][move[1]] == "*"
    end

    count
  end

  def self.neighbors(pos, size)
    neighbors = []

    (-1..1).each do |row|
      (-1..1).each do |col|
        if (0..(size-1)).include?(pos[0]+row) && (0..(size-1)).include?(pos[1]+col)
          neighbors << [pos[0]+row,pos[1]+col]
        end
      end
    end
    neighbors.delete(pos)
    neighbors
  end

end #end Board class


if __FILE__ == $PROGRAM_NAME
  if ARGV[0]
    YAML.load_file(ARGV.shift).play
  else
    size, mine_count = 16, 40
    game = Minesweeper.new(Board.new(size, mine_count))
    #p game.board.grid
    game.play
  end
end
