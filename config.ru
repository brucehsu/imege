$LOAD_PATH << '.'
require 'rack'
require 'json'
require 'digest'
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
		digest = Digest::SHA2.new

		filename = "#{digest.update(Time.now.to_i.to_s)}#{@@img_content_suffix[upload_file[:type]]}"
		Dir.mkdir 'img' unless Dir.exists? 'img'
		output = File.new(File.join('img',filename),'w')
		output.write(upload_file[:tempfile].read)
		output.flush
		output.close

		filename.to_json
	end
end

use Rack::ContentLength
use Rack::ContentType, 'application/json'
run Tank.new