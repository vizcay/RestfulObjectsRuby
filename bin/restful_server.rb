require 'restful_objects'

if ARGV[0].nil? then
  puts 'You must provide the script path to load: "restful_server script.rb"'
  exit(1)
end

load ARGV[0]

RestfulObjects::DomainModel.current.base_url = ARGV[1] || 'http://localhost:4567'
RestfulObjects::Server.run!

