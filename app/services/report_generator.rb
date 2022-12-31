class ReportGenerator
  include Days

  def initialize(type, date, client, api)
    date = Date.parse(date) unless date.is_a?(Date) # Must be a date object
    @api = api
    @type = type
    @start_date = date.beginning_of_year
    @end_date = type == 'pdf' ? date.end_of_year : date.yesterday
    @client = client
  end

  def make_report
  end

  private
  def pdf
    # to make things portable, maybe we use Prawn? I'm worried about the binary for wickedpdf
  end

  def xlsx
  end
end