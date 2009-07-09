# stdlib
require 'net/http'
require 'net/https'
require 'net/smtp'
require 'socket'
require 'timeout'
require 'xmlrpc/client'
require 'openssl'
require 'cgi'

# additional gems
require 'sinatra'
require 'json'

Sinatra::Application.set(
  :run => false,
  :environment => :production
)

require 'app.rb'
run Sinatra::Application