class ReportGenerator
  def initialize(type, start_date, end_date, client)
    @type = type
    @start_date = start_date
    @end_date = end_date
    @client = client
  end

  def make_report
  end

  private
  def pdf
  end

  def xlsx
  end
end