get '/' do
  'Hello Sinatra!'
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
    
    # filter out an LH ticket commands (we're only going to allow certain operations through commit msgs)
    body.gsub(/\[#[^]]*\]/, '')
    
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
    
    account = "http://#{ENV['LIGHTHOUSE_PROJECT']}.lighthouseapp.com"
    url = URI.parse('%s/projects/%d/changesets.xml' % [account, '33308'])
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth "#{ENV['LIGHTHOUSE_TOKEN']}", 'x'
    req.body = changeset_xml
    req.set_content_type('application/xml')
    Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }  
  end

  "Yay!"  
end

# get '/foo' do
#   commit_id = "53224cab8ddc8db0273b6ef43da083978c83a495"
#   added = commit['added'].map { |f| ['A', f] }
#   removed = commit['removed'].map { |f| ['R', f] }
#   modified = commit['modified'].map { |f| ['M', f] }
#   diff = YAML.dump(added + removed + modified)
# 
#   title = "Changeset [%s] by %s" % [commit_id, commit['author']['name']]
#   body = "#{commit['message']}\n#{commit['url']}"
#   changeset_xml = <<-XML.strip
#     <changeset>
#     <title>#{CGI.escapeHTML(title)}</title>
#     <body>#{CGI.escapeHTML(body)}</body>
#     <changes type="yaml">#{CGI.escapeHTML(diff)}</changes>
#     <committer>#{CGI.escapeHTML(commit['author']['name'])}</committer>
#     <revision>#{CGI.escapeHTML(commit_id)}</revision>
#     <changed-at type="datetime">#{CGI.escapeHTML(commit['timestamp'])}</changed-at>
#     </changeset>
#   XML
#   
#   account = "http://spree.lighthouseapp.com"
#   url = URI.parse('%s/projects/%d/changesets.xml' % [account, '33308'])
#   req = Net::HTTP::Post.new(url.path)
#   req.basic_auth '981b3fa74415cfd453f0113171770650ebd531df', 'x'
#   req.body = changeset_xml
#   req.set_content_type('application/xml')
#   Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }  
# 
#   "Yay!"  
# end
