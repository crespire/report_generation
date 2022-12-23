class ReportGenerator
  def initialize(type, start_date, end_date, client)
    @type = type
    @start_date = start_date
    @end_date = end_date
    @client = client
  end
end