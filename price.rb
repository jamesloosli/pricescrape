#!/usr/bin/env ruby

require 'rest_client'
require 'optparse'
require 'nokogiri'
require 'yaml'

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

def parse_tags
  node = YAML::parse(File.open('config/tags.yaml'))
  return node.to_ruby
end

def domain_str(link)
  domain = link.gsub(/http:\/\/\w+\.(\w+)\.\w.*/,'\1')
  return domain
end

def get_link(link)
  page = RestClient.get link
  return page
end

def get_price(page, path)
  x = Nokogiri::HTML.parse(page)
  price = x.xpath(path)
  return price
end

if __FILE__ == $0
  #do work
  #init some stuff
  options = parse_options
  tags = parse_tags

  domain = domain_str(options[:link])
  puts "Domain is #{domain}" if options[:verbose]

  puts "Getting link" if options[:verbose]
  page = get_link(options[:link])

  puts "Parsing HTML for price" if options[:verbose]
  price = get_price(page, tags[domain])

  puts price.to_s.split.join(" ")

end
