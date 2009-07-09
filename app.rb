# get '/' do
#   'Hello Sinatra!'
# end
get '/env' do
  ENV.inspect
end

post '/' do
  payload = JSON.parse(params[:payload])
 
  payload['commits'].each do |commit|
    next if commit['message'] =~ /^x /

    commit_id = commit['id']
    added = commit['added'].map { |f| ['A', f] }
    removed = commit['removed'].map { |f| ['R', f] }
    modified = commit['modified'].map { |f| ['M', f] }
    diff = YAML.dump(added + removed + modified)

    title = "Changeset [%s] by %s" % [commit_id, commit['author']['name']]
    body = "#{commit['message']}\n#{commit['url']}"
    changeset_xml = <<-XML.strip
      <changeset>
      <title>#{CGI.escapeHTML(title)}</title>
      <body>#{CGI.escapeHTML(body)}</body>
      <changes type="yaml">#{CGI.escapeHTML(diff)}</changes>
      <committer>#{CGI.escapeHTML(commit['author']['name'])}</committer>
      <revision>#{CGI.escapeHTML(commit_id)}</revision>
      <changed-at type="datetime">#{CGI.escapeHTML(commit['timestamp'])}</changed-at>
      </changeset>
    XML
    
    account = "http://spree.lighthouseapp.com"
    url = URI.parse('%s/projects/%d/changesets.xml' % [account, '33308'])
    req = Net::HTTP::Post.new(url.path)
puts ">>> #{ENV.inspect}"    
    req.basic_auth ENV['LIGHTHOUSE_TOKEN'], 'x'
    req.body = changeset_xml
puts ">>> " +   req.set_content_type('application/xml')
  end
  
  "Yay!"  
end
