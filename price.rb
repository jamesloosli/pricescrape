#!/usr/bin/env ruby

require 'rest_client'
require 'optparse'
require 'nokogiri'

def parse_options
  options = {}
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} [options]"
    opts.on('-l LINK','--link LINK','Provide the link to search') do |l|
      options[:link] = l
    end
    opts.on('-v','--verbose','Run verbosely') do |v|
      options[:verbose] = v
    end
    opts.on_tail('-h','--help','Display this screen') do
      puts opts
      exit
    end
  end

  begin
    optparse.parse!
    mandatory = [:link]
    missing = mandatory.select{ |param| options[param].nil? }
    if not missing.empty?
      puts "Missing options: #{missing.join(', ')}"
      puts optparse
      exit
    end
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $!.to_s
    puts optparse
    exit
  end

  if options[:verbose]
    puts "Options:"
    puts options.to_s
  end
  return options
end

def jenson_link(link)
  page = RestClient.get link
  x = Nokogiri::HTML.parse(page)
  price = x.xpath('//span[@itemprop = "price"]/span[@class = "Amount"]')
  return price
end

if __FILE__ == $0

  options = parse_options

  price = jenson_link(options[:link])
  puts price

end
