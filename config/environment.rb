require 'bundler/setup'

$root = File.expand_path('../..', __FILE__)
$: << File.expand_path('../../lib', __FILE__)

require 'active_record'
ActiveRecord::Base.logger = Logger.new(STDERR)

#require File.expand_path('../database', __FILE__)
#Rails.connect
