class ReportsController < ApplicationController
  def create
    # Recieve info from form, and query API to create based on type.
    # Maybe we need a ReportGenerator service object here?
  end

  private

  def report_params
    params.require(:report).permit(:client, :start_date, :end_date, :type)
  end
end
