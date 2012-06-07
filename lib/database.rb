require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/bookclaim.db")

class Book
  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  property :authors,      String
  property :thumbnail,    Text

  has n, :claims
end

class User
  include DataMapper::Resource

  property :id,           Serial
  property :username,     String
  property :password,     String
  property :admin,        Boolean
end

class Claim
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String
  property :note,         Text
  property :book_id,      Integer

  belongs_to :book
end

DataMapper.finalize.auto_migrate!