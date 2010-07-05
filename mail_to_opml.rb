require 'builder'

feeds = []
rss_dir = "#{ENV['HOME']}/Library/Mail/RSS"
files = Dir.glob(rss_dir + "/*.rssmbox")

files.each do |file|
  feed = {}
  
  if file =~ /.*\/(.*).rssmbox/
    feed[:name] = $1
  end
  next_line_is_value = false
  
  plist = File.new(file + "/Info.plist", "r")
  while(line = plist.gets)
    if next_line_is_value
      if line =~ /<string>(.*)<\/string>/
        feed[:url] = $1
      end
      next_line_is_value = false
    end
    
    if "<key>RSSFeedURLString</key>" == line.strip
      next_line_is_value = true
    end
  end
  
  feeds << feed
end

def feed_t_xml(feed, builder)
  builder.outline(
    :text     => feed[:name], 
    :title    => feed[:name], 
    :htmlUrl  => feed[:url], 
    :xmlUrl   => feed[:url],
    :type     => 'rss', )
end

x = Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
x.instruct!
x.opml {
  x.body {
    feeds.each { |f|  feed_t_xml(f, x) }
  }
}