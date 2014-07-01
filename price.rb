#!/usr/bin/env ruby

require 'rest_client'
require 'optparse'
require 'nokogiri'
require 'yaml'
require 'pp'

def parse_options
  options = {}
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} [options]"
    opts.on('-f FILE','--file FILE','Provide a file with multiple links, one per line') do |f|
      options[:file] = f
    end
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
    if options[:link].nil? && options[:file].nil? 
      puts "Please specify a link or a file to check, but not both."
      puts optparse
      exit
    elsif !options[:link].nil? && !options[:file].nil?
      puts "Please specify a link or a file to check, but not both."
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

def link_to_price(link, tags, verbose)
  domain = domain_str(link)

  puts tags[domain]

#  return "No template for domain: #{domain}" unless tags.has_key?("#{domain}")
#  puts "Domain is #{domain}" if verbose
#  puts "Getting link" if verbose
#  page = get_link(link)
#  puts "Parsing HTML for price" if verbose
#  price = get_price(page, tags[domain])

#  return price.to_s
end

if __FILE__ == $0
  #do work
  #init some stuff
  options = parse_options
  puts "Loading tags" if options[:verbose]
  tags = parse_tags
  puts "Tags loaded;" if options[:verbose]
  pp tags if options[:verbose]

  if options[:link].nil?
    f = File.open(options[:file])
    f.each_line do |link|
      puts "Checking link: #{link}" if options[:verbose]
      val =  link_to_price(link, tags, options[:verbose])
      puts val
    end
  else
    puts "Checking link: #{options[:link]}" if options[:verbose]
    val = link_to_price(options[:link],tags,options[:verbose])
    puts val
  end
end
