#!/usr/bin/env ruby

require 'rest_client'
require 'optparse'
require 'nokogiri'
require 'yaml'
require 'pp'
require 'uri'
require 'public_suffix'

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
  u = URI.parse(link)
  d = PublicSuffix.parse(u.host.to_s)
  return d.sld.to_s
end

def get_link(link)
  page = RestClient.get link
  return page
end

def get_price(page, path)
  x = Nokogiri::HTML.parse(page)
  price = x.xpath(path)
  price = price.to_s
  return price
end

def chomp_price(str)
  price = str.gsub(/[\s\n]+/,'').gsub(/\$/,'')
  return price
end

def link_to_price(link, tags, verbose)
  puts "Checking link: #{link}" if verbose
  domain = domain_str(link)
  unless tags.key?("#{domain}")
    puts "Domain #{domain} has no matching pattern" if verbose
    price = "0"
  else
    puts "Domain is #{domain}; using tag pattern; #{tags[domain]}" if verbose
    puts "Getting link" if verbose
    page = get_link(link)
    puts "Parsing HTML for price" if verbose
    price = get_price(page, tags[domain])
  end
  return chomp_price(price)
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
      link.chomp
      price = link_to_price(link, tags, options[:verbose])
      puts price
    end
  else
    pp options[:link]
    price = link_to_price(options[:link], tags, options[:verbose])
    puts price
  end
end
