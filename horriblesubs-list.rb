require "bundler"
require "open-uri"
require "json"
Bundler.require

def parse_link_xml(link_node)
    {
        type: link_node.text,
        link: link_node["href"]
    }
end

def parse_resolution_xml(res_node)
    {
        resolution: res_node.at_css('a[href="#"] > text()').text,
        filename: res_node.at_css("span.dl-label").text,
        links: res_node.css("span.ind-link > a").map(&method(:parse_link_xml))
    }
end

def parse_episode(ep_node)
    match = /^\(.+?\) (.*) - (\d*)$/.match(ep_node.at_css("text()").text)

    {
        show: match[1],
        ep_num: match[2].to_i,
        id: ep_node["id"],
        resolutions: ep_node.css("div.resolution-block.linkful").map(&method(:parse_resolution_xml))
    }
end

begin
    doc = Nokogiri::HTML(open("http://horriblesubs.info/lib/latest.php"))

    episodes = doc.css("div.episode").map(&method(:parse_episode))

    print JSON.pretty_generate(episodes)
rescue Exception => e
    print JSON.pretty_generate({error: e.to_s})
end
