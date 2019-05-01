INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]
GOES_FIRST = "Choose" # "Player", "Computer", or "Choose"

def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  system 'clear'
  puts "You're an #{PLAYER_MARKER}. The computer is #{COMPUTER_MARKER}."
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
end
# rubocop:enable Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def joinor(arr, delimiter=', ', word='or')
  case arr.size
  when 0 then ''
  when 1 then arr.first
  when 2 then arr.join(" #{word} ")
  else
    arr[-1] = "#{word} #{arr.last}"
    arr.join(delimiter)
  end
end

def find_at_risk_square(line, board, marker)
  if board.values_at(*line).count(marker) == 2
    board.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  end
end

def strategic_move(brd, marker)
  square = nil
  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, marker)
    return square if square
  end
  square
end

def computer_places_piece!(brd)
  square = strategic_move(brd, COMPUTER_MARKER)

  if !square
    square = strategic_move(brd, PLAYER_MARKER)
  end

  if brd[5] == INITIAL_MARKER
    brd[5] = COMPUTER_MARKER
  elsif !square
    square = empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end

  brd[square] = PLAYER_MARKER
end

def place_piece!(brd, current_player)
  if current_player.odd?
    player_places_piece!(brd)
  else
    computer_places_piece!(brd)
  end
end

def alternate_player(current_player)
  current_player + 1
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def display_score(player_wins, computer_wins)
  puts ""
  puts "Player has #{player_wins} wins."
  puts "Computer has #{computer_wins} wins."
  puts ""
end

def start_next_round(player_wins, computer_wins)
  return if player_wins >= 3 || computer_wins >= 3

  puts "Press enter to start the next round."
  gets
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def player_choice
  loop do
    puts "Enter 1 to go first or 2 to go second."
    choice = gets.chomp.to_i
    return choice if [1, 2].include?(choice)
    puts "Invalid Input"
  end
end

player_wins = 0
computer_wins = 0

who_goes_first = case GOES_FIRST
                 when "Choose"
                   player_choice
                 when "Player"
                   1
                 when "Computer"
                   2
                 end

loop do # main game loop
  board = initialize_board
  current_player = who_goes_first
  loop do
    display_board(board)

    place_piece!(board, current_player)
    current_player = alternate_player(current_player)
    break if someone_won?(board) || board_full?(board)
  end

  display_board(board)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won!"
  else
    prompt "It's a tie!"
  end

  if detect_winner(board) == 'Player'
    player_wins += 1
  elsif detect_winner(board) == 'Computer'
    computer_wins += 1
  end

  display_score(player_wins, computer_wins)

  start_next_round(player_wins, computer_wins)

  if player_wins >= 3 ||
     computer_wins >= 3
    prompt "Play again? (y or n)?"
    answer = gets.chomp
    break unless answer.downcase.start_with?('y')
  end
end

prompt "Goodbye"
