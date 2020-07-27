gem 'rss'
gem 'twitter'

require 'twitter'
require 'rss'
require 'open-uri'
require 'date'
require 'time'

# The API keys to post on Twitter. Remember to change them to your own.
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = 'consumer_key'
  config.consumer_secret     = 'consumer_secret'
  config.access_token        = 'access_token'
  config.access_token_secret = 'access_token_secret'
end

date_today = Date.today.to_s
time_now = Time.now.getlocal('UTC').to_s.split(' ')
time_now = time_now[1].split(':')
time_now = (time_now[0].to_i * 60) + time_now[1].to_i # We calculate the current time by changing it to a minute format

url = 'your_url/' # Remember to change to RSS feed

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

  # If there is a post that was published today, then will check if the post was posted within the last 2 hours. If both are true, then it will tweet. 
  if parced_date == date_today && time_now - parced_time < 120
    post_title = feed.channel.item.title.to_s
    post_link = feed.channel.item.link.to_s
    client.update "Jeg har lige postet en ny artikel kaldet \"#{post_title}\" den kan læses her:  #{post_link} #webudvikling #webdesign #multimediedesigner"
    puts 'A tweet has been posted'
  else
    puts 'There is no new posts to tweet about'
  end
end
