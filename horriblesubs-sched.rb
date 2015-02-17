require "bundler"
require "open-uri"
require "json"
Bundler.require

def parse_series(series_node)
    return if series_node["class"] != "series-name"

    {
        name: series_node.at_css("text()").text,
        release_time: series_node.at_css(".release-time").text
    }
end

def parse_weekday(weekday_node, list = [])
    return list if weekday_node == nil
    return list if weekday_node["class"] == "weekday"

    list << parse_series(weekday_node)

    parse_weekday(weekday_node.next, list)
end

begin
    doc = Nokogiri::HTML(open("http://horriblesubs.info/release-schedule/"))

    weekdays = doc.css("div.entry-content > h2.weekday")

    schedule = weekdays.map do |weekday_node|
        {
            name: weekday_node.at_css("text()").text,
            series: parse_weekday(weekday_node.next).compact
        }
    end

    print JSON.pretty_generate schedule
rescue Exception => e
    print JSON.pretty_generate({error: e.to_s})
end
