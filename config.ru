require 'rubygems'
require 'sinatra'

Sinatra::Application.set(
  :run => false,
  :environment => :production
)

require 'app.rb'
run Sinatra::Application