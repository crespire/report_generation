require 'json'
require 'net/http'

##
# This class represents the Clockify API

class Clockify
  ##
  # Creates a new instance of the API and initializes the API key.
  def initialize
    @authkey = Rails.application.credentials.clockify!
    @workspace = Rails.application.credentials.workspace!
    @uri_reports = "https://reports.api.clockify.me/v1"
    @uri_base = "https://api.clockify.me/api/v1"
  end


  ##
  # Creates a detailed report for the current @active_client based on the date range provided.
  #
  # +start_date+ is a string in the number format "%Y-%m-%d"
  #
  # +end_date+ is a string in the number format "%Y-%m-%d"

  def detailed_report(client, start_date, end_date)
    puts "Requesting data for #{client} from #{start_date} to #{end_date}"
    endpoint = "#{@uri_reports}/#{@workspace}/reports/detailed"
    uri = URI(endpoint)
    request = Net::HTTP::Post.new(uri, { 'Content-Type': 'application/json', 'X-Api-Key': @authkey })
    request.body = {
      # Required Info
      dateRangeStart: "#{start_date}T00:00:00.000",
      dateRangeEnd: "#{end_date}T23:59:59.000",
      detailedFilter: {
        page: 1,
        pageSize: 1000
      },

      # Filters
      exportType: 'JSON',
      clients: {
        contains: 'CONTAINS',
        ids: [client]
      },
      archived: false
    }.to_json
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    JSON.parse(response.body)
  end

  def projects(client)
    endpoint = "#{@uri_base}/#{@workspace}/projects"
    query = "?archived=false&page-size=5000&clients=#{client}"
    uri = URI(endpoint + query)
    request = Net::HTTP::Get.new(uri, { 'Content-Type': 'application/json', 'X-Api-Key': @authkey })
    response = Net::HTTP::start(uri.hostname, uri.port, use_ssl:true) { |http| http.request(request) }
    JSON.parse(response.body)
  end
end
