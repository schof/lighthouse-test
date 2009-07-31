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
require 'lighthouse'
require 'rack_hoptoad'

Sinatra::Application.set(
  :run => false,
  :environment => :production
)


use Rack::HoptoadNotifier, 'fc915153f36d08fc33aa4b9d6cc7382e'

require 'app.rb'
run Sinatra::Application
