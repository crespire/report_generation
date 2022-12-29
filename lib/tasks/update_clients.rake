# frozen_string_literal: true

namespace :ds do
  desc 'Updates clients against Designstor Clockify API'
  task update_clients: [:environment] do
    puts 'Updating clients...'
    endpoint = "https://api.clockify.me/api/v1/#{Rails.application.credentials.workspace!}/clients"
    query = '?archived=false&page-size=5000'
    uri = URI(endpoint + query)
    request = Net::HTTP::Get.new(uri, { 'Content-Type': 'application/json', 'X-Api-Key': Rails.application.credentials.clockify! })
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl:true) { |http| http.request(request) }
    updated = 0
    clients = JSON.parse(response.body)
    clients.map do |client|
      next if Client.exists?(id: client['id'])

      Client.create(id: client['id'], name: client['name'])
      updated += 1
    end
    puts "Added #{updated} records!"
  end
end