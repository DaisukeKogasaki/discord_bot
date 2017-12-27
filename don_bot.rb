require 'discordrb'
require 'yaml'

config = YAML.load_file("authentication.yml")

bot = Discordrb::Commands::CommandBot.new(
  token: config["Authentication"]["TOKEN"],
  client_id: config["Authentication"]["CLIENT_ID"],
  prefix: config["Authentication"]["PREFIX"]
)

bot.command :hello do |event|
 event.send_message("hello, #{event.user.name}!")
end

bot.command :donkatsu do |event|
  event.send_message(":innocent: :donkatsu: :innocent:")
end

bot.mention do |event|
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
