require 'restful_objects'

if ARGV.first.nil? then
  puts 'You must provide the script path to load: "restful_server script.rb"'
  exit(1)
end

load ARGV.first

RestfulObjects::DomainModel.current.base_url = 'http://localhost:4567'
RestfulObjects::Server.run!

