#!/usr/bin/env ruby

require 'json'
require 'gli'
require 'httpclient'
require 'pry'
require 'colorize'

class Balances
	attr_reader :loyalty, :credits
	def to_s
		"Balances: loyalty=#{@loyalty} credits=#{@credits}"
	end

	def initialize(json)
		@loyalty = json["Balances"]["Loyalty"]
		@credits = json["Balances"]["Credits"]
	end
end

class State
	attr_reader :allowed_moves, :result, :hand_value, :dealer_value
	def initialize(json)
		parse(json)
	end		

	def can_hit_or_stand?
		@allowed_moves.match(/.*Hit.*/) || false
	end

	def can_deal?
		@allowed_moves.match(/.*Deal.*/) || false
	end

	def offered_insurance?
		@allowed_moves == "Insurance" 
	end

	def can_proceed?
		can_hit_or_stand? || offered_insurance?
	end

	def to_s
		"State: allowed_moves=#{@allowed_moves} result=#{@result} hand_value=#{@hand_value} dealer_value=#{@dealer_value}"
	end
	private
	def parse(json)

		json["Payload"]["Commands"].each do | hash |
			# binding.pry
			if hash["Command"] == "AllowedMoves"
				@allowed_moves = hash["Actions"]
			elsif hash["Command"] == "Show"
				@result = hash["Result"]
			elsif hash["Command"] == "DealCard" && hash["Seat"] == -1
				@dealer_value = hash["Value"]
			elsif hash["Command"] == "DealCard" && hash["Seat"] == 1
				@hand_value = hash["Value"]
			end
		end
	end
end


	class BJClient
		def initialize(incubetsessionid, xruninstance)
			@client = HTTPClient.new
			@incubetsessionid = incubetsessionid
			@xruninstance = xruninstance
		end

		def start_new_round_bet_and_bet_amount(betamount: 1)
			puts ' - new round'
			@client.post('https://webgame.playstudios.com/game/bj/Deal', '{"Wagers":[0,100,0]}', get_secret_headers).content.force_encoding('UTF-8').sub("\xEF\xBB\xBF", "")

		end

		def hit
			puts ' - hit'

			@client.post('https://webgame.playstudios.com/game/bj/Hit', '{}', get_secret_headers).content.force_encoding('UTF-8').sub("\xEF\xBB\xBF", "")
		end

		def stand
			puts ' - stand'
			@client.post('https://webgame.playstudios.com/game/bj/stand', '{}', get_secret_headers).content.force_encoding('UTF-8').sub("\xEF\xBB\xBF", "")
		end

		def decline_insurance
			puts ' - decline insurance'

			@client.post('https://webgame.playstudios.com/game/bj/insurance', '{"InsuranceAccepted":[false,false,false]}', get_secret_headers).content.force_encoding('UTF-8').sub("\xEF\xBB\xBF", "")
		end

		private
		def get_secret_headers
			 {"incubet-sessionid" => @incubetsessionid, "X-Run-Instance" => @xruninstance}
		end
	end


$won = 0
$pushed = 0
$lost = 0

def print_result(state)
	case state.result
	when "Lose"
		$lost += 1
		"lost".red
	when "Win"
		$won += 1
		"won".green
	when "Push"
		$pushed += 1
		"pushed".green
	when "Blackjack"
		$won += 1
		"Blackjack".green
	when "Busted"
		$lost += 1
		"busted".red
	end
end

def random_sleep
	sleep(rand(0..1))
end

initial_state = %{
	{
  "Status": {
    "timestamp": "/Date(1440821359932)/"
  },
  "Balances": {
    "Premium": 0.0,
    "Credits": 725.0000,
    "Loyalty": 1040.0000,
    "Xp": 41062.0000,
    "LoyaltyBonus": [],
    "NextLoyaltyCliff": 0.4085,
    "Absolutes": [
      725.0000,
      41062.0000,
      1040.0000,
      0.0
    ],
    "Deltas": []
  },
  "Progressive": [],
  "Jackpots": {
    "BoundHighPercent": 1.0,
    "BoundLowPercent": 0.95,
    "ClientChangeRate": 0.027,
    "IsDisabled": false,
    "GameJackpots": []
  },
  "BuildingAccumulator": [],
  "ChangedQuests": [],
  "ChangedTrophies": [],
  "ChangedLevels": null,
  "ChangedAchievements": [],
  "Payload": {
    "Commands": [
      {
        "Seat": -1,
        "Hand": -1,
        "Command": "SetActive"
      },
      {
        "Rank": "9",
        "Suit": "c",
        "Value": "19",
        "Command": "FlipCard"
      },
      {
        "Seat": 1,
        "Hand": 0,
        "Command": "SetActive"
      },
      {
        "Result": "Lose",
        "Command": "Show"
      },
      {
        "Actions": "Deal",
        "Command": "AllowedMoves"
      }
    ],
    "Xp": 0.0
  },
  "NGCD": 0.0,
  "PendingUpgrades": []
}
}




state = State.new(JSON.parse(initial_state))

incubet = 'nneYcrdIgXI5PdSfU5AtUyTJbN3jdG-e_i_btdIue14.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjE0NDA5NjEyMDAsImlzc3VlZF9hdCI6MTQ0MDk1NDc1Niwib2F1dGhfdG9rZW4iOiJDQUFDUFkyVWVNR2dCQU5HWTM4VE5pYWlBZ2ppRk9RTGRYWXllSkxDR0d3am1wRlpBSVJnTzVrR1dGaXdDakhiMFpBZVg4M3lKRXh3VnlCT01FY1N3ZUNaQ2FJMEJaQ2U1Y2F6enFCd3ZDS25QbkhlSXlHQWE3TGUyNUE5NWVTQk5uVXVQaDU2c3V3cFpCdlpDeDBTNnl3NUpkandwYWpqUU9TV3FFT3UzY1pDV05UVjJhSEhIVlpCRGhZckE1ejRqSWNDdTJxZU5UYUlvbjBRajVNSHZwV3JaQiIsInRva2VuX2Zvcl9idXNpbmVzcyI6IkFieUhBNDIycXN3c0Nab3UiLCJ1c2VyIjp7ImNvdW50cnkiOiJjYSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMTUzOTg3MzM2NDkwMjUxIn0'
xrun = '2015-08-30T12:12:37.3849655-05:00'

bjclient = BJClient.new(incubet, xrun)


#binding.pry

max_rounds = 1000
original_balance = nil


(0..max_rounds).each do | current_round | 
	random_sleep
	if state.can_deal?
		puts "Starting a new round #{current_round} out of #{max_rounds}".blue
		response = bjclient.start_new_round_bet_and_bet_amount 
		original_balance = Balances.new(JSON.parse(response)) if original_balance == nil
		balances = original_balance
	end

	state = State.new(JSON.parse(response))
	balances = Balances.new(JSON.parse(response))

	puts state
	puts balances


	while state.can_proceed? do
		random_sleep
		if state.offered_insurance?
			puts "Insurance offerred, declining"
			response = bjclient.decline_insurance
		elsif state.hand_value.to_i < 13 || (state.hand_value.to_i  < 17 && state.dealer_value.to_i > 6)
			puts "Hand is #{state.hand_value}, hitting"
			response = bjclient.hit
		else
			response = bjclient.stand
			puts "Standing on #{state.hand_value}..."
		end
		state = State.new(JSON.parse(response))
		balances = Balances.new(JSON.parse(response))
		puts balances
		puts state
	end

	puts "Finished round:#{print_result state}"
	puts "Result of #{max_rounds} rounds: loyalty gain=#{balances.loyalty - original_balance.loyalty } chips gain=#{ balances.credits - original_balance.credits }"
	puts "Balances: #{balances}"
	puts "Won=#{$won} Lost=#{$lost} Pushed=#{$pushed}"


end



