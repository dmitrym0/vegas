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
	attr_reader :allowed_moves, :result, :hand_value
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
		"State: allowed_moves=#{@allowed_moves} result=#{@result} hand_value=#{@hand_value}"
	end
	private
	def parse(json)

		json["Payload"]["Commands"].each do | hash |

			if hash["Command"] == "AllowedMoves"
				@allowed_moves = hash["Actions"]
			elsif hash["Command"] == "Show"
				@result = hash["Result"]
			elsif hash["Command"] == "DealCard"
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
			@client.post('https://webgame.playstudios.com/game/bj/Deal', '{"Wagers":[0,10,0]}', get_secret_headers).content.force_encoding('UTF-8').sub("\xEF\xBB\xBF", "")

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


def print_result(state)
	case state.result
	when "Lose"
		"lost".red
	when "Win"
		"won".green
	when "Push"
		"pushed".green
	when "Blackjack"
		"dealer Blackjack".red
	when "Busted"
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

# json_test = %{
# 	{
#   "Status": {
#     "timestamp": "/Date(1440820260920)/"
#   },
#   "Balances": {
#     "Premium": 0.0,
#     "Credits": 780.0000,
#     "Loyalty": 1040.0000,
#     "Xp": 41025.0000,
#     "LoyaltyBonus": [],
#     "NextLoyaltyCliff": 0.0646,
#     "Absolutes": [
#       780.0000,
#       41025.0000,
#       1040.0000,
#       0.0
#     ],
#     "Deltas": []
#   },
#   "Progressive": [],
#   "Jackpots": {
#     "BoundHighPercent": 1.0,
#     "BoundLowPercent": 0.95,
#     "ClientChangeRate": 0.027,
#     "IsDisabled": false,
#     "GameJackpots": [
#       {
#         "GameName": "FrontierFortune",
#         "Balance": 9572110.09,
#         "MinLineBet": 500.0,
#         "Disabled": false,
#         "WinEvents": [
#           {
#             "FacebookAppScopedId": "1052917464",
#             "AmountWon": 8589643.33
#           },
#           {
#             "FacebookAppScopedId": "100002260006977",
#             "AmountWon": 7164421.51
#           },
#           {
#             "FacebookAppScopedId": "1539053365",
#             "AmountWon": 11039939.86
#           },
#           {
#             "FacebookAppScopedId": "100007009924785",
#             "AmountWon": 12666435.61
#           },
#           {
#             "FacebookAppScopedId": "1801925872",
#             "AmountWon": 7587304.63
#           },
#           {
#             "FacebookAppScopedId": "100004905009429",
#             "AmountWon": 8559535.12
#           },
#           {
#             "FacebookAppScopedId": "100000683847657",
#             "AmountWon": 7915203.52
#           },
#           {
#             "FacebookAppScopedId": "1568434125",
#             "AmountWon": 7318252.33
#           },
#           {
#             "FacebookAppScopedId": "1152627827",
#             "AmountWon": 7600403.65
#           },
#           {
#             "FacebookAppScopedId": "698733663",
#             "AmountWon": 7868647.45
#           },
#           {
#             "FacebookAppScopedId": "100001957496457",
#             "AmountWon": 7860533.41
#           },
#           {
#             "FacebookAppScopedId": "613018668",
#             "AmountWon": 11118287.14
#           },
#           {
#             "FacebookAppScopedId": "100004003158720",
#             "AmountWon": 8018999.74
#           },
#           {
#             "FacebookAppScopedId": "100005617180971",
#             "AmountWon": 7517805.64
#           },
#           {
#             "FacebookAppScopedId": "582050466",
#             "AmountWon": 7074598.81
#           },
#           {
#             "FacebookAppScopedId": "1801925872",
#             "AmountWon": 7630879.15
#           },
#           {
#             "FacebookAppScopedId": "1416682730",
#             "AmountWon": 11048052.58
#           },
#           {
#             "FacebookAppScopedId": "1539053365",
#             "AmountWon": 7228468.9
#           },
#           {
#             "FacebookAppScopedId": "100002372846471",
#             "AmountWon": 8583548.56
#           },
#           {
#             "FacebookAppScopedId": "100000054581381",
#             "AmountWon": 8336395.06
#           }
#         ]
#       },
#       {
#         "GameName": "AroundTheWorld",
#         "Balance": 18907725.64,
#         "MinLineBet": 500.0,
#         "Disabled": false,
#         "WinEvents": [
#           {
#             "FacebookAppScopedId": "682467013",
#             "AmountWon": 11592489.47
#           },
#           {
#             "FacebookAppScopedId": "579388049",
#             "AmountWon": 19623851.66
#           },
#           {
#             "FacebookAppScopedId": "100000062747761",
#             "AmountWon": 23530928.34
#           },
#           {
#             "FacebookAppScopedId": "1301424434",
#             "AmountWon": 25260005.31
#           },
#           {
#             "FacebookAppScopedId": "100002987156296",
#             "AmountWon": 31395073.77
#           },
#           {
#             "FacebookAppScopedId": "1189069586",
#             "AmountWon": 23001258.15
#           },
#           {
#             "FacebookAppScopedId": "1533514885",
#             "AmountWon": 15712726.26
#           },
#           {
#             "FacebookAppScopedId": "536446599",
#             "AmountWon": 22750214.9
#           },
#           {
#             "FacebookAppScopedId": "100000466378760",
#             "AmountWon": 18980305.44
#           },
#           {
#             "FacebookAppScopedId": "100002278021351",
#             "AmountWon": 32238336.16
#           },
#           {
#             "FacebookAppScopedId": "100004041566601",
#             "AmountWon": 13878764.56
#           },
#           {
#             "FacebookAppScopedId": "165702457",
#             "AmountWon": 42159177.97
#           },
#           {
#             "FacebookAppScopedId": "100002533763522",
#             "AmountWon": 17808713.89
#           },
#           {
#             "FacebookAppScopedId": "100000348657482",
#             "AmountWon": 15170649.98
#           },
#           {
#             "FacebookAppScopedId": "1679274299",
#             "AmountWon": 25229267.27
#           },
#           {
#             "FacebookAppScopedId": "100007016897069",
#             "AmountWon": 25506668.85
#           },
#           {
#             "FacebookAppScopedId": "100004464940207",
#             "AmountWon": 21955770.56
#           },
#           {
#             "FacebookAppScopedId": "826005011",
#             "AmountWon": 15201483.05
#           },
#           {
#             "FacebookAppScopedId": "100000875324687",
#             "AmountWon": 17268579.01
#           },
#           {
#             "FacebookAppScopedId": "100005017563722",
#             "AmountWon": 13508099.11
#           }
#         ]
#       },
#       {
#         "GameName": "Betrock",
#         "Balance": 21587804.5,
#         "MinLineBet": 500.0,
#         "Disabled": false,
#         "WinEvents": [
#           {
#             "FacebookAppScopedId": "100003365411096",
#             "AmountWon": 44050769.5
#           },
#           {
#             "FacebookAppScopedId": "100004728018972",
#             "AmountWon": 40894739.5
#           },
#           {
#             "FacebookAppScopedId": "100000403389066",
#             "AmountWon": 24381719.5
#           },
#           {
#             "FacebookAppScopedId": "787955407",
#             "AmountWon": 44486648.5
#           },
#           {
#             "FacebookAppScopedId": "1376884916",
#             "AmountWon": 21715163.5
#           },
#           {
#             "FacebookAppScopedId": "514100635",
#             "AmountWon": 21760334.5
#           },
#           {
#             "FacebookAppScopedId": "100000229100710",
#             "AmountWon": 44493376.0
#           },
#           {
#             "FacebookAppScopedId": "1846381927",
#             "AmountWon": 45022126.0
#           },
#           {
#             "FacebookAppScopedId": "607678774",
#             "AmountWon": 21448831.0
#           },
#           {
#             "FacebookAppScopedId": "100004590198330",
#             "AmountWon": 41119343.5
#           },
#           {
#             "FacebookAppScopedId": "1229689131",
#             "AmountWon": 23828980.0
#           },
#           {
#             "FacebookAppScopedId": "100003112678686",
#             "AmountWon": 39605350.0
#           },
#           {
#             "FacebookAppScopedId": "788315315",
#             "AmountWon": 22528255.0
#           },
#           {
#             "FacebookAppScopedId": "100002193707506",
#             "AmountWon": 24640933.0
#           },
#           {
#             "FacebookAppScopedId": "100007803424804",
#             "AmountWon": 41552923.0
#           },
#           {
#             "FacebookAppScopedId": "100000399051050",
#             "AmountWon": 22759366.0
#           },
#           {
#             "FacebookAppScopedId": "100003365411096",
#             "AmountWon": 51459862.0
#           },
#           {
#             "FacebookAppScopedId": "713663243",
#             "AmountWon": 50719715.5
#           },
#           {
#             "FacebookAppScopedId": "612491220",
#             "AmountWon": 31103927.5
#           },
#           {
#             "FacebookAppScopedId": "100000156256242",
#             "AmountWon": 54878498.5
#           }
#         ]
#       },
#       {
#         "GameName": "NYNY",
#         "Balance": 8036484.5,
#         "MinLineBet": 200.0,
#         "Disabled": false,
#         "WinEvents": [
#           {
#             "FacebookAppScopedId": "1679261494",
#             "AmountWon": 10990469.0
#           },
#           {
#             "FacebookAppScopedId": "100006060151377",
#             "AmountWon": 8025869.0
#           },
#           {
#             "FacebookAppScopedId": "10207199278648055",
#             "AmountWon": 9383493.5
#           },
#           {
#             "FacebookAppScopedId": "1129080428",
#             "AmountWon": 7821744.5
#           },
#           {
#             "FacebookAppScopedId": "593684244",
#             "AmountWon": 8389452.5
#           },
#           {
#             "FacebookAppScopedId": "100001166473241",
#             "AmountWon": 7525731.5
#           },
#           {
#             "FacebookAppScopedId": "100001410725011",
#             "AmountWon": 9941780.0
#           },
#           {
#             "FacebookAppScopedId": "1095433405",
#             "AmountWon": 9808092.5
#           },
#           {
#             "FacebookAppScopedId": "1066584066",
#             "AmountWon": 12527097.5
#           },
#           {
#             "FacebookAppScopedId": "100000497562896",
#             "AmountWon": 12785886.95
#           },
#           {
#             "FacebookAppScopedId": "770735031",
#             "AmountWon": 8101771.1
#           },
#           {
#             "FacebookAppScopedId": "100001166473241",
#             "AmountWon": 7443879.5
#           },
#           {
#             "FacebookAppScopedId": "100004899811218",
#             "AmountWon": 7996208.45
#           },
#           {
#             "FacebookAppScopedId": "100009126811884",
#             "AmountWon": 7493453.0
#           },
#           {
#             "FacebookAppScopedId": "1167903583",
#             "AmountWon": 9666598.55
#           },
#           {
#             "FacebookAppScopedId": "100006388419061",
#             "AmountWon": 20643602.45
#           },
#           {
#             "FacebookAppScopedId": "1226738780",
#             "AmountWon": 11531969.0
#           },
#           {
#             "FacebookAppScopedId": "100006303190068",
#             "AmountWon": 8189980.1
#           },
#           {
#             "FacebookAppScopedId": "1248304396",
#             "AmountWon": 10104115.7
#           },
#           {
#             "FacebookAppScopedId": "1314754071",
#             "AmountWon": 8519102.0
#           }
#         ]
#       },
#       {
#         "GameName": "Sheerluck",
#         "Balance": 19550350.0,
#         "MinLineBet": 500.0,
#         "Disabled": false,
#         "WinEvents": [
#           {
#             "FacebookAppScopedId": "1012193213",
#             "AmountWon": 15865784.0
#           },
#           {
#             "FacebookAppScopedId": "750645261",
#             "AmountWon": 22955332.0
#           },
#           {
#             "FacebookAppScopedId": "10203317309554083",
#             "AmountWon": 21483276.0
#           },
#           {
#             "FacebookAppScopedId": "100006278402794",
#             "AmountWon": 21186748.0
#           },
#           {
#             "FacebookAppScopedId": "1481985284",
#             "AmountWon": 22663172.0
#           },
#           {
#             "FacebookAppScopedId": "669831083",
#             "AmountWon": 17409000.0
#           },
#           {
#             "FacebookAppScopedId": "100008033823361",
#             "AmountWon": 30688696.0
#           },
#           {
#             "FacebookAppScopedId": "574685617",
#             "AmountWon": 25230054.0
#           },
#           {
#             "FacebookAppScopedId": "574685617",
#             "AmountWon": 27004850.0
#           },
#           {
#             "FacebookAppScopedId": "687081626",
#             "AmountWon": 20775684.0
#           },
#           {
#             "FacebookAppScopedId": "100001010511182",
#             "AmountWon": 19914712.0
#           },
#           {
#             "FacebookAppScopedId": "100001010511182",
#             "AmountWon": 17367132.0
#           },
#           {
#             "FacebookAppScopedId": "100002486025129",
#             "AmountWon": 17970652.0
#           },
#           {
#             "FacebookAppScopedId": "1012193213",
#             "AmountWon": 25994812.0
#           },
#           {
#             "FacebookAppScopedId": "100000469542850",
#             "AmountWon": 22819048.0
#           },
#           {
#             "FacebookAppScopedId": "813099656",
#             "AmountWon": 28873052.0
#           },
#           {
#             "FacebookAppScopedId": "100000469542850",
#             "AmountWon": 38196322.0
#           },
#           {
#             "FacebookAppScopedId": "1649044724",
#             "AmountWon": 29247210.0
#           },
#           {
#             "FacebookAppScopedId": "100004010756607",
#             "AmountWon": 15914224.0
#           },
#           {
#             "FacebookAppScopedId": "100004283704144",
#             "AmountWon": 16149768.0
#           }
#         ]
#       },
#       {
#         "GameName": "Beanstalk",
#         "Balance": 30788306.5,
#         "MinLineBet": 500.0,
#         "Disabled": false,
#         "WinEvents": [
#           {
#             "FacebookAppScopedId": "460526064121445",
#             "AmountWon": 21465286.0
#           },
#           {
#             "FacebookAppScopedId": "1396424714018409",
#             "AmountWon": 26734384.0
#           },
#           {
#             "FacebookAppScopedId": "100000464294165",
#             "AmountWon": 25879556.5
#           },
#           {
#             "FacebookAppScopedId": "838765679",
#             "AmountWon": 27031054.0
#           },
#           {
#             "FacebookAppScopedId": "100000883378035",
#             "AmountWon": 22492456.0
#           },
#           {
#             "FacebookAppScopedId": "100000486317884",
#             "AmountWon": 22986583.0
#           },
#           {
#             "FacebookAppScopedId": "100000117775351",
#             "AmountWon": 23310614.5
#           },
#           {
#             "FacebookAppScopedId": "855730483",
#             "AmountWon": 26896138.0
#           },
#           {
#             "FacebookAppScopedId": "518911657",
#             "AmountWon": 27689813.5
#           },
#           {
#             "FacebookAppScopedId": "100001677986019",
#             "AmountWon": 28068821.5
#           },
#           {
#             "FacebookAppScopedId": "1226738780",
#             "AmountWon": 31122206.5
#           },
#           {
#             "FacebookAppScopedId": "100001677986019",
#             "AmountWon": 26651437.0
#           },
#           {
#             "FacebookAppScopedId": "508597517",
#             "AmountWon": 37978181.5
#           },
#           {
#             "FacebookAppScopedId": "1705351290",
#             "AmountWon": 26953628.5
#           },
#           {
#             "FacebookAppScopedId": "1547935276",
#             "AmountWon": 22823944.0
#           },
#           {
#             "FacebookAppScopedId": "100005058062835",
#             "AmountWon": 21643000.0
#           },
#           {
#             "FacebookAppScopedId": "100000003333510",
#             "AmountWon": 24114358.0
#           },
#           {
#             "FacebookAppScopedId": "100000421150407",
#             "AmountWon": 24348640.0
#           },
#           {
#             "FacebookAppScopedId": "100002324368064",
#             "AmountWon": 22534309.0
#           },
#           {
#             "FacebookAppScopedId": "573518352",
#             "AmountWon": 23111536.0
#           }
#         ]
#       },
#       {
#         "GameName": "Mirage",
#         "Balance": 21953806.45,
#         "MinLineBet": 500.0,
#         "Disabled": false,
#         "WinEvents": [
#           {
#             "FacebookAppScopedId": "711801081",
#             "AmountWon": 29769578.35
#           },
#           {
#             "FacebookAppScopedId": "100001186815363",
#             "AmountWon": 35967982.75
#           },
#           {
#             "FacebookAppScopedId": "10154107015140179",
#             "AmountWon": 23566807.15
#           },
#           {
#             "FacebookAppScopedId": "100003692307577",
#             "AmountWon": 26241982.75
#           },
#           {
#             "FacebookAppScopedId": "1200361324",
#             "AmountWon": 46187694.1
#           },
#           {
#             "FacebookAppScopedId": "100005124467258",
#             "AmountWon": 60763857.85
#           },
#           {
#             "FacebookAppScopedId": "1000673465",
#             "AmountWon": 26626137.25
#           },
#           {
#             "FacebookAppScopedId": "1163713677",
#             "AmountWon": 32431046.95
#           },
#           {
#             "FacebookAppScopedId": "100000549481722",
#             "AmountWon": 21618068.35
#           },
#           {
#             "FacebookAppScopedId": "100000429921492",
#             "AmountWon": 33183115.75
#           },
#           {
#             "FacebookAppScopedId": "638028135",
#             "AmountWon": 26887421.5
#           },
#           {
#             "FacebookAppScopedId": "800288355",
#             "AmountWon": 27943700.8
#           },
#           {
#             "FacebookAppScopedId": "1349707196",
#             "AmountWon": 21698522.65
#           },
#           {
#             "FacebookAppScopedId": "745378298826708",
#             "AmountWon": 47306381.2
#           },
#           {
#             "FacebookAppScopedId": "1019934988",
#             "AmountWon": 60764087.05
#           },
#           {
#             "FacebookAppScopedId": "100000513794936",
#             "AmountWon": 23562845.05
#           },
#           {
#             "FacebookAppScopedId": "1599226173",
#             "AmountWon": 43564007.2
#           },
#           {
#             "FacebookAppScopedId": "100000500546948",
#             "AmountWon": 41762442.1
#           },
#           {
#             "FacebookAppScopedId": "1120174595",
#             "AmountWon": 25692262.9
#           },
#           {
#             "FacebookAppScopedId": "1230985751",
#             "AmountWon": 41831053.15
#           }
#         ]
#       }
#     ]
#   },
#   "BuildingAccumulator": [
#     {
#       "AttributesId": "mi_marquee",
#       "Name": "Marquee",
#       "Points": 2,
#       "PointsRequired": 2,
#       "Price": 0
#     },
#     {
#       "AttributesId": "mi_gate",
#       "Name": "Gate",
#       "Points": 4,
#       "PointsRequired": 4,
#       "Price": 0
#     },
#     {
#       "AttributesId": "mi_atrium",
#       "Name": "Atrium",
#       "Points": 4,
#       "PointsRequired": 4,
#       "Price": 0
#     },
#     {
#       "AttributesId": "mi_secretgarden",
#       "Name": "Secret Garden",
#       "Points": 1,
#       "PointsRequired": 4,
#       "Price": 0
#     },
#     {
#       "AttributesId": "mi_volcano",
#       "Name": "Volcano",
#       "Points": 0,
#       "PointsRequired": 4,
#       "Price": 0
#     },
#     {
#       "AttributesId": "mi_statue",
#       "Name": "Statue",
#       "Points": 0,
#       "PointsRequired": 6,
#       "Price": 0
#     },
#     {
#       "AttributesId": "mi_tower",
#       "Name": "Tower",
#       "Points": 0,
#       "PointsRequired": 8,
#       "Price": 0
#     }
#   ],
#   "ChangedQuests": [],
#   "ChangedTrophies": [],
#   "ChangedLevels": null,
#   "ChangedAchievements": [],
#   "Payload": {
#     "Commands": [
#       {
#         "Rank": "K",
#         "Suit": "h",
#         "Seat": 1,
#         "Hand": 0,
#         "Value": "20",
#         "BS": false,
#         "Command": "DealCard"
#       },
#       {
#         "Actions": "Hit, Stand",
#         "Command": "AllowedMoves"
#       }
#     ],
#     "Xp": 0.0
#   },
#   "NGCD": 0.0,
#   "PendingUpgrades": []
# }
# }



# b =  Balances.new(json)
# a = State.new(json)
# puts a.can_deal? 
# puts "hitme" if a.can_hit_or_stand?


state = State.new(JSON.parse(initial_state))

incubet = 'Q7pw__ECG5TKUfqyFR5O9C6NxA28wXWb5slcXWsJMZM.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjE0NDA4ODIwMDAsImlzc3VlZF9hdCI6MTQ0MDg3NTQwMiwib2F1dGhfdG9rZW4iOiJDQUFDUFkyVWVNR2dCQUVuamxTVEp3RWU1TnFiOGRyYllxN29obklvOXFZd01DbFQyV3Zoek5BRmF2aUEwUVhiYWxKOEZXS1cwdUdPVDVaQlBXNzBYWWlPQ0hVNWlmQktUelpCZXRFZDBsbjlOVkNHaWY5MmtUSDMwcDBYejVBSDAydlQydDZEcHh6ZW9aQzNpeTRSYVZ5Z1BnRE85NDNPVmpNU09EdDFVeXRrcWphMzRTTUdCNFA4SjdYU29PRVNtMDRZUEF5WkM5VlNzT25PVVpCRkZNIiwidG9rZW5fZm9yX2J1c2luZXNzIjoiQWJ5SEE0MjJxc3dzQ1pvdSIsInVzZXIiOnsiY291bnRyeSI6ImNhIiwibG9jYWxlIjoiZW5fVVMiLCJhZ2UiOnsibWluIjoyMX19LCJ1c2VyX2lkIjoiMTAxNTM5ODczMzY0OTAyNTEifQ'
xrun = '2015-08-29T14:35:29.4444891-05:00'

bjclient = BJClient.new(incubet, xrun)


max_rounds = 4
original_balance = nil

# binding.pry

(0..max_rounds).each do | current_round | 
	random_sleep
	if state.can_deal?
		puts "Starting a new round #{current_round} out of #{max_rounds}".blue
		response = bjclient.start_new_round_bet_and_bet_amount 
		original_balance = Balances.new(JSON.parse(response)) if original_balance == nil
		balances = original_balance
		#puts response
		#File.open("json", 'w') { |file| file.write(response) }

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
		elsif state.hand_value.to_i < 16 
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


end



