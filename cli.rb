#!/usr/bin/env ruby

require 'yaml'
require 'digest'
require 'rest-core'

if ARGV.size < 1
	puts 'No file to be uploaded'
	exit(1)
end

config_path = File.join(Dir.home, '.imege')

unless File.exists?(config_path)
	# asks user about username and password
	# then write digest into .imege as YAML
end

config = YAML::load(File.new(config_path))
digest = Digest::SHA2.new(512)
digest << config[:token] << config[:digest]
secret = digest.hexdigest

ImegeClient = RC::Builder.client do
  use RC::DefaultSite , config[:site]
  use RC::JsonResponse, true
end

client = ImegeClient.new
remote_filename = client.put('/upload',{:file=>File.new(ARGV[0]), 
	:token=>config[:token],
	:secret=>secret},{},{})

puts "#{config[:site]}/img/#{remote_filename}"