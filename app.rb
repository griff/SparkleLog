#!/usr/bin/env ruby
require File.expand_path('../config/environment', __FILE__)

require 'sinatra'
unless production?
  require 'sinatra/activerecord'
  require 'sparkle_log'

  set :database, "sqlite3:///db/production.db"
end

get '/' do
  redirect to('/index.html')
end

def file_or_make(file, cmd=file)
  f = File.expand_path("#{file}.json", settings.public_folder)
  send_file f if File.exist?(f)
  halt 404 if settings.production?

  if cmd==file
    SparkleLog.send cmd
  else
    SparkleLog.send cmd, file
  end
end

get '/percent.json' do
  file_or_make(:percent)
end

get '/support.json' do
  file_or_make(:support)
end

get '/all.json' do
  file_or_make(:all)
end

get '/:version.json' do
  file_or_make(params[:version], :version)
end