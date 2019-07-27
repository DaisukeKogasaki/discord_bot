require 'discordrb'
require 'yaml'
require 'nokogiri'
require 'open-uri'

class DonBot
  yaml_file = File.exist?("./local_authentication.yml") ? "local_authentication.yml" : "authentication.yml"
  config = YAML.load_file(yaml_file)
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
      event.send_message(":heart:")
    when 1..70
      event.send_message("せやな")
    when 71..99
      event.send_message("せやろか")
    else
      event.send_message("error")
    end
  end

  bot.command(:server_status, attributes = {:description => "Shows all server status at discord's voice chat."}) do |event|
    url = 'https://status.discordapp.com/'
    charset = nil
    html = open(url) do |f|
        charset = f.charset
        f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)

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

  riot_api_key = config["RiotAPI"]["KEY"]
  bot.command(:lol, attributes = { :description => "Show LoL's summoner profiles" }) do |event, sname, reg|
    region = reg.nil? ? "jp1" : reg
    summoner_name = sname
    summoner_uri = URI.parse("https://#{region}.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{sname}?api_key=#{riot_api_key}")
    return_summoner_data = Net::HTTP.get(summoner_uri)
    summoer_info = JSON.parse(return_summoner_data)
    return event.send_message "該当のサモナーが存在しません" unless summoer_info["status"].nil?
    summoner_id = summoer_info["id"]
    league_uri = URI.parse("https://#{region}.api.riotgames.com/lol/league/v3/positions/by-summoner/#{summoner_id}?api_key=#{riot_api_key}")
    event.send_message "#{summoer_info["name"]}のリーグ情報"
    return_league_data = Net::HTTP.get(league_uri)
    league_info = JSON.parse(return_league_data)
    return event.send_message "リーグ情報がありません" if league_info.empty?
    message = "#{league_info[0]["leagueName"]}\n"
    message << "#{league_info[0]["tier"]} #{league_info[0]["rank"]} (#{league_info[0]["leaguePoints"]}LP)\n"
    win_late = (league_info[0]["wins"].to_f / (league_info[0]["wins"] + league_info[0]["losses"])).round(2) * 100
    message << "#{league_info[0]["wins"]}wins/#{league_info[0]["losses"]}losses (#{win_late}%)"
    event.send_message message
  end

  # WIP
  # bot.command(:embed, attributes = {:description => "embed test."}) do |event|
  #   event.channel.send_embed do |embed|
  #     embed.title = 'fugafuga'
  #     embed.url = 'https://qiita.com/tenmihi/items/23052f57256ccf3223d3'
  #     embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'hoge-san')
  #     embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://i.imgur.com/PcMltU7.jpg')
  #     embed.color = "#00ff00"
  #   end
  # end

  bot.run
end

DonBot.new