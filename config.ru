require 'rubygems'
require 'sinatra'
require 'json'

Sinatra::Application.set(
  :run => false,
  :environment => :production
)

require 'app.rb'
run Sinatra::Application