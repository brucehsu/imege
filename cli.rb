#!/usr/bin/env ruby

require 'io/console'
require 'yaml'
require 'digest'
require 'rest-core'
require 'openssl'
require 'pbkdf256'
require 'json'

IMEGE_SERVER_URL = 'http://YOUR.URL.HERE'

config_path = File.join(Dir.home, '.imege')

ImegeClient = RC::Builder.client do
  use RC::DefaultSite , IMEGE_SERVER_URL
  use RC::JsonResponse, true
end

client = ImegeClient.new

unless File.exists?(config_path)
	# asks user about username and password
	# then write digest into .imege as YAML
  # Use hashed username as token and hashed password as digest
  # Hash function: PBKDF256
  print 'Username: '
  username = STDIN.gets.strip
  print 'Password: '
  passwd = STDIN.noecho(&:gets).strip
  puts ''

  digest = Digest::SHA2.new(512)
  digest << username
  token = digest.hexdigest

  salt = OpenSSL::Random.random_bytes(16)

  digest = PBKDF256.pbkdf2_sha256(passwd, salt, 1353, 16).unpack('H*')[0]

  res = client.post("/register",{:token=>token, :digest=>digest})

  if res==nil
    puts 'Cannot connect remote server'
    exit 2
  elsif res["Success"]
    yaml = {:token=>token, :digest=>digest, :site=>IMEGE_SERVER_URL}
    config = File.open(config_path, 'w')
    config.write(yaml.to_yaml.to_s)
    config.flush
    config.close
    puts 'Successfully registered'
  elsif res["Failed"]
    puts "Register failed: #{res["Failed"]}"
    exit 1
  else
    puts 'Unknown error'
    exit 3
  end
end

if ARGV.size < 1
  puts 'No file to be uploaded'
  exit(1)
end

config = YAML::load(File.new(config_path))
digest = Digest::SHA2.new(512)
digest << config[:token] << config[:digest]
secret = digest.hexdigest

ARGV.length.times do |i|
    remote_filename = client.put('/upload',{:file=>File.new(ARGV[i]), 
        :token=>config[:token],
        :secret=>secret},{},{})

    puts "#{IMEGE_SERVER_URL}/img/#{remote_filename}"
end