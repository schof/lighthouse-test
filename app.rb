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

    # filter out an LH ticket commands (we're only going to allow certain operations through commit msgs)
    next unless regex_match = /\[#[0-9]*/.match(commit['message'])
    ticket_id = regex_match[0].gsub('[#', '')
    commit['message'] = commit['message'].gsub(/\[#[^]]*\]/, '')

    title = "Changeset [%s] by %s" % [commit_id, commit['author']['name']]
    body = "#{commit['message']}\n#{commit['url']}\n[##{ticket_id}]"
        
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
    
    account = "http://#{ENV['LIGHTHOUSE_ACCOUNT']}.lighthouseapp.com"
    url = URI.parse('%s/projects/%d/changesets.xml' % [account, ENV['LIGHTHOUSE_PROJECT']])
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth "#{ENV['LIGHTHOUSE_TOKEN']}", 'x'
    req.body = changeset_xml
    req.set_content_type('application/xml')
    Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }  

    # udpate the lighthouse ticket and mark as patched (when applicable)
    Lighthouse.token = ENV['LIGHTHOUSE_TOKEN']
    Lighthouse.account = ENV['LIGHTHOUSE_ACCOUNT']
    project = Lighthouse::Project.find(ENV['LIGHTHOUSE_PROJECT'])
    
    ticket = Lighthouse::Ticket.find(ticket_id, :params => {:project_id => ENV['LIGHTHOUSE_PROJECT']})
    # TDODO -- determine ticket number, etc.
  end

  "Yay!"  
end


