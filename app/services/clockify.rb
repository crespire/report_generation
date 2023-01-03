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
  # Creates a detailed report based on the parameters provided.
  #
  # +client_id+ is a string of the client's Clockify ID
  #
  # +client_name+ is the name of the client
  #
  # +start_date+ is a string in the number format "%Y-%m-%d"
  #
  # +end_date+ is a string in the number format "%Y-%m-%d"

  def detailed_report(client_id, start_date, end_date)
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
        ids: [client_id]
      },
      archived: false
    }.to_json
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    JSON.parse(response.body)
  end

  def projects(client)
    endpoint = "#{@uri_base}/#{@workspace}/projects"
    query = "?archived=false&page-size=5000&sort-order=DESCENDING&clients=#{client}"
    uri = URI(endpoint + query)
    request = Net::HTTP::Get.new(uri, { 'Content-Type': 'application/json', 'X-Api-Key': @authkey })
    response = Net::HTTP::start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    JSON.parse(response.body)
  end

  def has_tasks?(client_id, date)
    endpoint = "#{@uri_reports}/#{@workspace}/reports/summary"
    uri = URI(endpoint)
    request = Net::HTTP::Post.new(uri, { 'Content-Type': 'application/json', 'X-Api-Key': @authkey })
    request.body = {
      # Required Info
      dateRangeStart: "#{date.beginning_of_year}T00:00:00.000",
      dateRangeEnd: "#{date.end_of_year}T23:59:59.000",
      summaryFilter: {
        groups: %w[CLIENT TASK],
        sortColumn: 'GROUP'
      },

      # Filter to requested client
      clients: {
        ids: [client_id],
        contains: 'CONTAINS'
      }
    }.to_json
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body)
    data['totals'].first.is_a? Hash
  end
end
