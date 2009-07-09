get '/' do
  'Hello Sinatra!'
end

post '/' do
  payload = JSON.parse(params[:payload])
  #messages = []
  #repository = payload['repository']
 
  #payload['commits'].each do |sha, commit|
  #  Campfire.notify("[%s] %s - %s %s" % [ repository['name'], commit['author']['name'], commit['message'], commit['url'] ])
  #end  
  #push = JSON.parse(params[:payload])
  puts ">>> I got some JSON: #{payload.inspect}"
  "I got some JSON: #{payload.inspect}" 
end
