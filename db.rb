require 'data_mapper'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/database.db")

class User
	include DataMapper::Resource

	property :id, Serial
	property :token, String, :unique=>true
	property :digest, String
	property :created_at, DateTime
end


DataMapper.auto_upgrade!
DataMapper.finalize