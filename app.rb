require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/json'
require 'sinatra/respond_with'
require 'sinatra/reloader' if development?
require 'net/http'
require 'json'
require 'curb'
require 'haml'

require './lib/database'

enable :sessions
respond_to :html, :json
config_file 'config.yml'

#look at pulling helpers into own file
helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic Realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    # TODO: Use database for authentication here
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
  end

  def partial(page, options={}, locals={})
    haml page.to_sym, options.merge!(:layout => false), locals
  end

  def book_query(query)
    Curl::Easy.perform("https://www.googleapis.com/books/v1/volumes?q=#{URI.encode query}&maxResults=40&key=#{settings.apikey}").body_str
  end
end

get '/' do
  haml :index
end

get '/admin/?' do
  protected!
  @route = { method: "DELETE", action: "/books"}
  @books = Book.all
  haml :admin
end

get '/books/?' do
  @route = { method: "POST", action: "/claims"}
  @books = Book.all
  haml :books
end

post '/books/?'  do
  book = Book.new(
    title:       params["title"] || "",
    authors:     params["authors"] || "",
    thumbnail:   params["thumbnail"].gsub("&edge=curl", "") || ""
  )

  book.save!

  # TODO handle success/failure
  logger.info book ? "Added book: #{book.inspect}" : "Failed adding claim with params: #{params.inspect}"
  redirect back
end

delete '/books/:id/?' do
  protected!
  Book.get(params[:id]).destroy
  logger.info "Deleted book with id: #{params[:id]}"
end

post '/claims/?' do
  claim = Claim.new(
      book_id: params[:book_id] || "",
      name:    params[:name] || "",
      note:    params[:note] || ""
  )

  claim.save!

  #TODO handle success/failure
  logger.info claim ? "Added claim: #{claim.inspect}" : "Failed adding claim with params: #{params.inspect}"
  redirect back
end

get '/search/?' do
  redirect back unless defined? params[:q]

  @query  = params[:q]
  @result = book_query(@query)
  @search_results  = JSON.parse(@result)["items"]

  @route = { method: "POST", action: "/books" }
  respond_to do |f|
    f.html { haml back.to_sym }
    f.json { params[:q].nil? ? json({totalItems: 0}) : @result }
  end
end