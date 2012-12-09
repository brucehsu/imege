$LOAD_PATH << '.'
require 'rack'
require 'json'
require 'digest'
require 'jellyfish'
require 'pry'
require 'db'

class Tank
	include Jellyfish

	@@img_type = ['.jpg','.png']
	@@img_content_type = {'.jpg'=>'image/jpeg', '.png'=>'image/png'}
	@@img_content_suffix = @@img_content_type.invert

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
		output = File.new(filename,'w')
		output.write(upload_file[:tempfile].read)
		output.flush
		output.close

		filename.to_json
	end
end

use Rack::ContentLength
use Rack::ContentType, 'application/json'
run Tank.new