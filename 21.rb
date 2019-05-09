WINNING_TOTAL = 21
DEALER_STAY_VALUE = 17
ACE_DIFFERENCE = 10
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

def hand_value(hand)
  result = basic_card_values(hand)
  hand.map(&:values).flatten.select { |value| value == 11 }.count.times do
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

def determine_winner(player_hand, dealer_hand)
  if hand_value(player_hand) > hand_value(dealer_hand)
    "Player wins"
  elsif hand_value(player_hand) < hand_value(dealer_hand)
    "Dealer wins"
  else
    "Tie"
  end
end

loop do
  system 'clear'
  deck = initialize_deck
  player_hand = []
  dealer_hand = []
  initial_deal(deck, player_hand)
  initial_deal(deck, dealer_hand)

  puts "21"
  puts ""
  puts "J, Q, K = 10"
  puts "      A = 1 or 11"
  puts ""
  puts "Player: #{hand_display(player_hand)}"
  puts "Dealer: #{dealer_hand[0].keys}"
  puts ""

  loop do
    if hand_value(player_hand) < WINNING_TOTAL
      prompt("Hit or stay?")
      answer = gets.chomp.downcase
      if ["h", "hit"].include?(answer)
        player_hand << draw_card(deck)
        puts ""
        puts "Player: #{hand_display(player_hand)}"
        puts "Dealer: #{dealer_hand[0].keys}"
        puts ""
      else
        break
      end
    elsif busted?(player_hand)
      puts ""
      puts "Player busts"
      puts "Dealer wins"
      puts ""
      return
    else
      break
    end
  end

  loop do
    if busted?(dealer_hand)
      puts ""
      puts "Player: #{hand_display(player_hand)}"
      puts "Dealer: #{hand_display(dealer_hand)}"
      puts ""
      puts ""
      puts "Dealer busts"
      puts "Player wins"
      puts ""
      break
    elsif hand_value(dealer_hand) < DEALER_STAY_VALUE
      dealer_hand << draw_card(deck)
    else
      puts ""
      puts "Player: #{hand_display(player_hand)}"
      puts "Dealer: #{hand_display(dealer_hand)}"
      puts ""
      puts determine_winner(player_hand, dealer_hand)
      break
    end
  end
  break
end
