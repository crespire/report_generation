class ReportsController < ApplicationController
  DAY_STANDARD = 7

  def new
    render :new
  end

  def budgets
    date = Date.parse(params[:date])
    puts "Budgets action: #{params['client']} for #{date}"
    @client_name = Client.find(params['client']).name
    @client_id = params['client']
    @date = params['date']
    @api = Clockify.new
    @projects = @api.projects(@client_id)
    render :budgets
  end

  def create
    # Recieve info from form, and query API to create based on type.
    # Maybe we need a ReportGenerator service object here?
    redirect_to action: 'budgets', params: report_params.reject { |k| k['authenticity_token'] || k['commit'] } and return if params[:type] == 'pdf'

    puts params[:client]
    date = Date.parse(params[:date])
    puts date
    puts date.beginning_of_year
    puts params[:type]
  end

  def create_pdf
    puts 'Create PDF after getting budgets'
  end

  private

  def report_params
    params.permit(:authenticity_token, :commit, :client, :date, :type, budgets: [])
  end
end
