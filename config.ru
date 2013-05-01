$LOAD_PATH << '.'
require 'json'
require 'digest'
require 'rack'
require 'jellyfish'
require 'db'

class Tank
	include Jellyfish

	@@img_type = ['.jpg','.png']
	@@img_content_type = {'.jpg'=>'image/jpeg', '.png'=>'image/png'}
	@@img_content_suffix = @@img_content_type.invert

	get %r{\/img\/(.+)$} do |match|

		filename = match[0][1..-1]
		unless File.exists? filename
			status 404 
			'Not found'
		else
			headers 'Content-Type'=>@@img_content_type[File.extname(filename)]
			File.read(filename)
		end
	end

	post '/register' do
		token = request.params['token']
		digest = request.params['digest']

		user = User.new(:token=>token, :digest=>digest, :created_at=>Time.now)
		begin
			if user.save!
				{"Success"=>user.id}.to_json
			else 
				{"Failed"=>"Cannot create user"}.to_json
			end
		rescue => e
			if e.class== IntegrityError
				{"Failed"=>"User already existed"}.to_json
			end
		end

	end

	put '/upload' do
		upload_file = request.params['file']
		client_token = request.params['token']
		client_secret = request.params['secret']

		'Error' unless upload_file[:type].include? 'image/'

		user_record = User.first(:token=>client_token)
		digest = Digest::SHA2.new(512)
		digest << user_record.token << user_record.digest
		valid_secret = digest.hexdigest

		'Error' unless valid_secret == client_secret
		file_content = upload_file[:tempfile].read
		digest = Digest::SHA2.new

		filename = "#{digest.update(file_content)}#{@@img_content_suffix[upload_file[:type]]}"
		filepath = File.join('img',filename)
		Dir.mkdir 'img' unless Dir.exists? 'img'
		unless File.exists?(filepath)
			output = File.new(filepath,'w')
			output.write(file_content)
			output.flush
			output.close
		end

		filename.to_json
	end
end

use Rack::ContentLength
use Rack::ContentType, 'application/json'
use Rack::Chunked
use Rack::ConditionalGet
use Rack::ETag
run Tank.new
