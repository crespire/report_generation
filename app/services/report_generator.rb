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
    # to make things portable, maybe we use Prawn? I'm worried about the binary for wickedpdf
  end

  def xlsx
  end
end