WINNING_TOTAL = 21
DEALER_STAY_VALUE = 17
ACE_DIFFERENCE = 10
TOP_SCORE = 3
DECK = [
  { "A-H" => 11 }, { "2-H" => 2 }, { "3-H" => 3 }, { "4-H" => 4 },
  { "5-H" => 5 }, { "6-H" => 6 }, { "7-H" => 7 }, { "8-H" => 8 },
  { "9-H" => 9 }, { "10-H" => 10 },
  { "J-H" => 10 }, { "Q-H" => 10 }, { "K-H" => 10 },
  { "A-D" => 11 }, { "2-D" => 2 }, { "3-D" => 3 }, { "4-D" => 4 },
  { "5-D" => 5 }, { "6-D" => 6 }, { "7-D" => 7 }, { "8-D" => 8 },
  { "9-D" => 9 }, { "10-D" => 10 },
  { "J-D" => 10 }, { "Q-D" => 10 }, { "K-D" => 10 },
  { "A-S" => 11 }, { "2-S" => 2 }, { "3-S" => 3 }, { "4-S" => 4 },
  { "5-S" => 5 }, { "6-S" => 6 }, { "7-S" => 7 }, { "8-S" => 8 },
  { "9-S" => 9 }, { "10-S" => 10 },
  { "J-S" => 10 }, { "Q-S" => 10 }, { "K-S" => 10 },
  { "A-C" => 11 }, { "2-C" => 2 }, { "3-C" => 3 }, { "4-C" => 4 },
  { "5-C" => 5 }, { "6-C" => 6 }, { "7-C" => 7 }, { "8-C" => 8 },
  { "9-C" => 9 }, { "10-C" => 10 },
  { "J-C" => 10 }, { "Q-C" => 10 }, { "K-C" => 10 }
]

def prompt(msg)
  puts "=> #{msg}"
end

def draw_card(deck)
  deck.pop
end

def busted?(hand)
  hand_value(hand) > WINNING_TOTAL
end

def basic_card_values(hand)
  hand.map(&:values).flatten.reduce(:+)
end

def ace_count(hand)
  hand.map(&:values).flatten.select { |value| value == 11 }.count
end

def hand_value(hand)
  result = basic_card_values(hand)
  ace_count(hand).times do
    result -= ACE_DIFFERENCE if result > WINNING_TOTAL
  end

  result
end

def hand_display(hand)
  hand.map(&:keys).flatten
end

def initialize_deck
  DECK.shuffle!
end

def initial_deal(deck, hand)
  2.times do
    hand << draw_card(deck)
  end
end

def find_winner(player_hand, dealer_hand)
  if hand_value(player_hand) > hand_value(dealer_hand)
    "Player wins the round"
  elsif hand_value(player_hand) < hand_value(dealer_hand)
    "Dealer wins the round"
  else
    "Tie"
  end
end

def player_top_score?(player_wins)
  player_wins == TOP_SCORE
end

def dealer_top_score?(dealer_wins)
  dealer_wins == TOP_SCORE
end

def header_display
  <<~MSG
     Twenty-One
     Enter "hit" or "h" to hit, or just press enter to stay
     Play to: #{TOP_SCORE} wins

     J, Q, K = 10
     A = 1 or 11

  MSG
end

def turn_one_display(player_hand, dealer_hand)
  <<~MSG

     Player: #{hand_display(player_hand)}
     Dealer: #{dealer_hand[0].keys}

     MSG
end

def turn_two_display(player_hand, dealer_hand)
  <<~MSG

     Player: #{hand_display(player_hand)}
     Dealer: #{hand_display(dealer_hand)}

     MSG
end

def player_bust_message
  <<~MSG

     Player busts
     Dealer wins the round

     MSG
end

def dealer_bust_message
  <<~MSG

     Dealer busts
     Player wins the round

     MSG
end

def display_score(player_wins, dealer_wins)
  <<~MSG

     Player has #{player_wins} wins
     Dealer has #{dealer_wins} wins

     MSG
end

player_wins = 0
dealer_wins = 0

loop do
  loop do
    system 'clear'
    deck = initialize_deck
    player_hand = []
    dealer_hand = []
    initial_deal(deck, player_hand)
    initial_deal(deck, dealer_hand)

    puts header_display
    puts turn_one_display(player_hand, dealer_hand)

    loop do
      if hand_value(player_hand) < WINNING_TOTAL
        prompt("Hit or stay?")
        answer = gets.chomp.downcase
        if ["h", "hit"].include?(answer)
          player_hand << draw_card(deck)
          puts turn_one_display(player_hand, dealer_hand)
        else
          @player_hand ||= player_hand
          break
        end
      else
        @player_hand ||= player_hand
        break
      end
    end

    if busted?(@player_hand)
      puts player_bust_message
      dealer_wins += 1
      @player_hand = nil
      break
    end

    loop do
      if busted?(dealer_hand)
        puts turn_two_display(@player_hand, dealer_hand)
        puts dealer_bust_message
        player_wins += 1
        @player_hand = nil
        @dealer_hand = nil
        break
      elsif hand_value(dealer_hand) < DEALER_STAY_VALUE
        dealer_hand << draw_card(deck)
      else
        @dealer_hand ||= dealer_hand
        puts turn_two_display(@player_hand, @dealer_hand)
        puts find_winner(@player_hand, @dealer_hand)
        if find_winner(@player_hand, @dealer_hand) == "Player wins the round"
          player_wins += 1
        elsif find_winner(@player_hand, @dealer_hand) == "Dealer wins the round"
          dealer_wins += 1
        end
        @player_hand = nil
        @dealer_hand = nil
        break
      end
    end
    @player_hand = nil
    @dealer_hand = nil
    break
  end
  puts display_score(player_wins, dealer_wins)
  if player_top_score?(player_wins)
    puts "Player wins the game!"
  elsif dealer_top_score?(dealer_wins)
    puts "Dealer wins the game!"
  end
  break if player_top_score?(player_wins) || dealer_top_score?(dealer_wins)
  puts "Press enter to start the next round"
  gets
end
