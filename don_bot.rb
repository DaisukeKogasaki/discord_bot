require 'discordrb'
require 'yaml'
require 'nokogiri'
require 'open-uri'


config = YAML.load_file("authentication.yml")
setting = config["Authentication"]

bot = Discordrb::Commands::CommandBot.new(
  token: setting["TOKEN"],
  client_id: setting["CLIENT_ID"],
  prefix: setting["PREFIX"]
)

bot.command(:hello, attributes = {:description => "don-bot sais hello for you."}) do |event|
  event.send_message("<@#{event.user.id}> Hello.")
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
    event.send_message("error")
  end
end

ErangelDropSpots = ['Rozhok', 'School', 'Apartments', 'Yasnaya Polyana', 'Severny', 'Shooting Range',
                    'Mansion', 'Prison', 'Mylta', 'Mylta Power', 'Novolepnoye', 'Military', 'Ferry Pier',
                    'Primorsk', 'Hospital', 'Georgopol Crates', 'Georgopol South', 'Georgopol North',
                    'Zharki', 'Stalber', 'Kameshki', 'Pochinki', 'Ruins', 'Water Town', 'Farm']
MiramarDropSpots = ['Pecado', 'San Martin', 'Hacienda del Patron', 'Minas Generales', 'Monte Nuevo',
                    'Chumacera', 'Los Leones', 'Puerto Paraiso', 'Impala', 'El Azahar', 'Cruz del Valle',
                    'La Cobreria', 'El Pozo', 'Valle del Mar', 'Prison', 'Los Higos', 'Power Grid',
                    'Water Treatment', 'Torre Ahumada', 'Campo Militar', 'La Bendita', 'East Islands']

bot.command(:goto, attributes = {:description => "don-bot will decide the destination instead of you at PUBG."}) do |event, map|
  case map
  when "e", "erange", "Erange"
    event.send_message("'#{ErangelDropSpots[rand(ErangelDropSpots.count)]}'に行きましょう！")
  when "m", "miramar", "Miramar"
    event.send_message("'#{MiramarDropSpots[rand(MiramarDropSpots.count)]}'に行きましょう！")
  else
    event.send_message("エラーです、以下を入力してください\n```孤島マップ：'e', 'erange', 'Erange'\n砂漠マップ：'m', 'miramar', 'Miramar'```")
  end
end

url = 'https://status.discordapp.com/'
charset = nil
html = open(url) do |f|
    charset = f.charset
    f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)

bot.command(:server_status, attributes = {:description => "Shows all server status at discord's voice chat."}) do |event|
  doc.xpath('//div[@class="child-components-container "]').each do |node|
    server = []
    status = []
    node.css('span').children.each_with_index do |result, i|
      unless (i + 1) % 2 == 0
        server << result.inner_text.gsub((/\n| /), "").strip.ljust(10, " ")
      else
        status << result.inner_text.gsub(/\n/, "").strip
      end
    end
    server_status = server.zip(status)
    say_status = "現在のサーバーのステータス(`Operational` : :white_check_mark:)\n```\n"
    server_status.each{ |i, word| say_status << ("#{i} : #{word}\n") }
    say_status << "```"

    event.send_message say_status
    break # コマンド終了後に`0`が表示される問題の仮対応
  end
end

rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
rate_limiter.bucket :example, delay: 5  # 5 seconds between each execution
bot.message(containing: ['(╯°□°）╯︵ ┻━┻', '(ﾉಥ益ಥ）ﾉ﻿ ┻━┻', '(ノಠ益ಠ)ノ彡┻━┻']) do |event|
  next if rate_limiter.rate_limited?(:example, event.channel)
  event.respond '┬─┬ノ( º _ ºノ)'
end

bot.message(containing: ['せやな']) do |event|
  next if rate_limiter.rate_limited?(:example, event.channel)
  event.respond 'せやろか'
end

bot.command(:profile, attributes = {:description => "don-bot teaches your profile."}) do |event|
  message = "<@#{event.user.id}>のプロフィール\n"
  message << "User Name : #{event.user.username}\n"
  # message << "Role : #{event.user.roles}\n"
  message << "Avatar Image : #{event.user.avatar_url}\n"
  event.send_message message
end

bot.run
