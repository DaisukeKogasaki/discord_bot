require 'discordrb'

bot = Discordrb::Commands::CommandBot.new(
  token: 'MzkyMzI0Njc4NzYyNDk2MDAw.DRlncA.d_ybtlaHzz01Y6fupMaIwsRBTWY',
  client_id: 392324678762496000,
  prefix:'/'
)

bot.command :hello do |event|
 event.send_message("hello, #{event.user.name}!")
end

bot.command :tube do |event|
  event.send_message("https://www.youtube.com/results?search_query=pubg")
end

bot.command :seyana do |event|
  flg = rand(100)
  case flg
  when 0
    event.send_message("死ね")
  when 1..70
    event.send_message("せやな")
  when 71..99
    event.send_message("せやろか")
  else
    event.send_message("WTF")
  end
end

bot.run
