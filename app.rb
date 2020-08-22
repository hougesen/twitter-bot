require 'date'
require 'dotenv/load'
require 'open-uri'
require 'rss'
require 'time'
require 'twitter'

# The API keys to post on Twitter. Remember to change them to your own.
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

date_today = Date.today.to_s
time_now = Time.now.getlocal('UTC').to_s.split(' ')
time_now = time_now[1].split(':')
time_now = (time_now[0].to_i * 60) + time_now[1].to_i # We calculate the current time by changing it to a minute format

url = ENV['RSS_FEED']
URI.open(url) do |rss|
  feed = RSS::Parser.parse(rss)

  post_date = feed.channel.item.pubDate.to_s
  post_date = post_date.split(' ')

  # The date format of RSS is different from Ruby's so we have to format it.
  # We start by formating the post date
  parced_date = []
  parced_date.push(post_date[3])
  case post_date[2]
  when 'Jan'
    parced_date.push('01')
  when 'Feb'
    parced_date.push('02')
  when 'Mar'
    parced_date.push('03')
  when 'Apr'
    parced_date.push('04')
  when 'May'
    parced_date.push('05')
  when 'Jun'
    parced_date.push('06')
  when 'Jul'
    parced_date.push('07')
  when 'Aug'
    parced_date.push('08')
  when 'Sep'
    parced_date.push('09')
  when 'Oct'
    parced_date.push('10')
  when 'Nov'
    parced_date.push('11')
  when 'Dec'
    parced_date.push('12')
  end
  parced_date.push(post_date[1])
  parced_date = parced_date.join('-')

  # We then format the post time
  parced_time = post_date[4].split(':')
  parced_time = parced_time[0].to_i * 60 + parced_time[1].to_i

  # If there is a post that was published today, then will check if the post was posted within the last 2 hours.
  # If both are true, then it will tweet.
  if parced_date == date_today && time_now - parced_time < 120
    post_title = feed.channel.item.title.to_s
    post_link = feed.channel.item.link.to_s
    all_items = feed.channel.item.to_s.split(' ')
    string = "Jeg har lige postet en ny artikel kaldet \"#{post_title}\" den kan læses her: #{post_link}"

    # For converting Wordpress category/tags into strings
    all_categorys = []
    i = 0
    while i < all_items.length
      all_categorys.push(all_items[i]) if all_items[i].include? 'category'
      i += 1
    end
    j = 0
    while j < all_categorys.length
      all_categorys[j].slice! '<category>'
      all_categorys[j].slice! '</category>'
      string += " ##{all_categorys[j]}"
      j += 1
    end

    client.update string
    puts 'A tweet has been posted'

  else
    puts 'There is no new posts to tweet about'
  end
end
