class Minesweeper

  def initialize(board)
    @board = board
    @display = Array.new(9){Array.new(9)}
  end

  def play
    #until game over?

    #prompt player to move
    #player makes a move
    #reveal a square/squares on @display
    row, col = prompt
    reveal([row, col])

  end

  def reveal(pos)
    square =  @board.grid[pos[0]][pos[1]]

    if square == "*"
      return "Game Over"

    # if a number, don't recurse
    elsif square != 0
      @display[pos[0]][pos[1]] = square.to_s
    else #0 or blank case
      #go to each adjacent square, calling with reveal(new pos)
      # function that gets positions_num generates array called neighbors
      #neighbors.each do |pos|
      #check display
        #reveal (pos)
      #end
      #then call reveal on neighbors if NOT revealed
        @display[pos[0]][pos[1]] = " "
        Board.neighbors(pos).each do |move|

          reveal(move) if @display[move[0]][move[1]].nil?

        end

    end



  end

  def prompt
    "Pick a Row: "
    row = gets.chomp
    "Pick a Col: "
    col = gets.chomp

    return row, col
  end

end

class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(9){Array.new(9)}

    #populate bombs
    10.times {
      num = rand(0..80)
      row = num / 9
      col = num % 9
      while !@grid[row][col].nil?
         num = rand(0..80)
         row = num / 9
         col = num % 9
      end
      @grid[row][col] = "*"
    }

    #populate numbers
    @grid.each_with_index do |row, idx|
      row.each_with_index do |col, idx2|
        if @grid[idx][idx2] != "*"
          @grid[idx][idx2] = count_bomb([idx,idx2])
        end
      end
    end
  end

  def player_move(pos)
    if @grid[pos[0]][pos[1]] == "*"
      return "GAME OVER"
    end
  end

  def count_bomb (pos) #pos is NOT bomb
    count = 0

    (-1..1).each do |row|
      (-1..1).each do |col|
        if (0..8).include?(pos[0]+row) && (0..8).include?(pos[1]+col)
          count += 1 if @grid[pos[0]+row][pos[1]+col] == "*"
        end
      end
    end

    count
  end

  def self.neighbors(pos)
    neighbors = []

    (-1..1).each do |row|
      (-1..1).each do |col|
        if (0..8).include?(pos[0]+row) && (0..8).include?(pos[1]+col)
          neighbors << [pos[0]+row,pos[1]+col]
        end
      end
    end
    neighbors.delete(pos)
    neighbors
  end


end
