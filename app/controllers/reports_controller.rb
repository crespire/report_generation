require('zip')

class ReportsController < ApplicationController
  DAY_STANDARD = 7

  def new
    render :new
  end

  def budgets
    date = Date.parse(params[:date])
    puts "Budgets action: #{params[:client]} for #{date}"
    @client_name = Client.find(params[:client]).name
    @client_id = params[:client]
    @date = date
    @api = Clockify.new
    @projects = @api.projects(@client_id)
    render :budgets
  end

  def create
    # If PDF, we need more information
    redirect_to action: 'budgets', params: report_params.reject { |k| k['authenticity_token'] || k['commit'] } and return if params[:type] == 'pdf'

    # Otherwise, generate XLSX reporting
    @api = Clockify.new
    date = Date.parse(params[:date])
    @projects = Hash.new { |hash, key| hash[key] = [] }
    @client_id = params[:client]
    @client_name = Client.find(params[:client]).name
    @last_end = Days.prior_weekday(date, 'Sunday')
    @last_start = Days.prior_weekday(@last_end, 'Monday')

    json = @api.detailed_report(@client_id, @client_name, @last_start, @last_end)
    raise "Error: #{json['code']} #{json['message']}" if json.key?('code')

    json['timeentries'].each do |entry|
      entry_start = DateTime::iso8601(entry['timeInterval']['start'])
      entry_end = DateTime::iso8601(entry['timeInterval']['end'])
      duration_seconds = entry['timeInterval']['duration']

      @projects[entry['projectName']].push(
        {
          client: entry['clientName'],
          description: entry['description'],
          task: entry['taskID'],
          user: entry['userName'],
          email: entry['userEmail'],
          billable: entry['billable'] ? 'Yes' : 'No',
          start_date: entry_start.strftime('%d/%m/%Y'),
          start_time: entry_start.strftime('%T'),
          end_date: entry_end.strftime('%d/%m/%Y'),
          end_time: entry_end.strftime('%T'),
          duration_h: Time.at(duration_seconds).utc.strftime('%H:%M:%S'),
          duration_d: (duration_seconds / (60.0 * 60.0)).round(2),
          duration_sec: duration_seconds,
          rate: '100.00',
          amount: (100.00 * (duration_seconds / (60.0 * 60.0))).round(2)
        }
      )
    end

    Axlsx::Package.new do |file|
      @projects.each do |project, tasks_array|
        file.workbook.add_worksheet(name: project) do |sheet|
          style = sheet.styles
          money_style = style.add_style num_fmt: 4
          bold_text = style.add_style b: true
          outline_style = style.add_style border: 1

          day_start = @last_start.strftime('%B %d')
          day_end = @last_start.month == @last_end.month ? @last_end.strftime('%d') : @last_end.strftime('%B %d')
          sheet.add_row ["Week #{@last_end.cweek} (#{day_start} - #{day_end})".upcase], style: [bold_text]
          sheet.add_row(
            [
              'Project',
              'Client',
              'Description',
              'Task',
              'User',
              'Email',
              'Billable',
              'Start Date',
              'Start Time',
              'End Date',
              'End Time',
              'Duration (h)',
              'Duration (decimal)',
              'Billable Rate (CAD)',
              'Billable Amount (CAD)',
              'User',
              'Days',
              'Total Days'
            ],
            style: bold_text
          )

          row_ind = 3
          tasks_by_day = tasks_array.group_by { |task| task[:start_date] }
          tasks_by_day.each do |day, tasks|
            day_hours = 0
            day_start_ind = row_ind.clone
            by_user = tasks.group_by { |task| task[:user] }
            by_user.each do |user, user_tasks|
              user_day_hours = 0
              user_tasks.each do |task|
                user_day_hours += task[:duration_d]
                sheet.add_row(
                  [
                    project.to_s,
                    task[:client],
                    task[:description],
                    task[:task],
                    task[:user],
                    task[:email],
                    task[:billable],
                    task[:start_date],
                    task[:start_time],
                    task[:end_date],
                    task[:end_time],
                    task[:duration_h],
                    task[:duration_d],
                    task[:rate],
                    task[:amount],
                    task[:user]
                  ]
                )
                row_ind += 1
              end
              # Summary row per user, per day
              day_hours += user_day_hours
              sheet.add_row(
                [
                  nil,
                  nil,
                  "Total for #{user} (#{day})",
                  nil,
                  nil,
                  nil,
                  nil,
                  nil,
                  nil,
                  nil,
                  nil,
                  nil,
                  user_day_hours,
                  nil,
                  nil,
                  nil,
                  "=ROUND(M#{row_ind}/#{DAY_STANDARD}, 2)"
                ],
                style: bold_text
              )
              row_ind += 1
            end

            # Spacer row
            sheet.add_row
            row_ind += 1

            # Sum total row
            sheet.add_row(
              [
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                "Total Hours #{day}",
                day_hours,
                nil,
                nil,
                nil,
                'Total Days',
                "=ROUND(SUM(Q#{day_start_ind}:Q#{row_ind - 1}), 2)"
              ],
              style: bold_text
            )
            row_ind += 1

            # Spacer
            sheet.add_row
            row_ind += 1
          end

          sheet.column_widths 15, 10, 35, 10, 15, 15, 5, 10, 10, 10, 10, 25, 7, 10, 10, 10, 5, 5
        end
      end
      filename = "#{@client_name}_tasks_summary_ending_#{@last_end.strftime('%F')}.xlsx"
      begin
        workbook = Tempfile.new(['temp', '.xlsx'])
        file.serialize(workbook)
        data = File.read(workbook.path)
        send_data(data, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: filename)
      ensure
        workbook.close!
      end
    end
  end

  def create_pdf
    puts 'Create PDF after getting budgets'
    @projects = Hash.new do |hash, key| 
      hash[key] = Hash.new do |projects, week|
        projects[week] = Hash.new do |week, user|
          week[user] = Hash.new do |user, day|
            user[day] = []
          end
        end
      end
    end
    @api = Clockify.new
    date = Date.parse(params[:date])
    @first_day = date.beginning_of_year
    @last_day = date
    @client_name = params[:client_name]
    @client_id = params[:client_id]

    json = @api.detailed_report(@client_id, @client_name, @first_day, date)
    raise "Error: #{json['code']} #{json['message']}" if json.key?('code')

    json['timeentries'].each do |entry|
      float_time = entry['timeInterval']['duration'] / (60 * 60.0)
      date = Date.iso8601(entry['timeInterval']['start'])
      week = date.cweek
      @projects[entry['projectName']][week][entry['userName']][date] << float_time
    end

    report_template = File.read("#{Rails.root}/app/services/report_template.html.erb")
    erb = ERB.new(report_template, trim_mode: '<>')
    @project_budgets = params[:budgets].transform_values(&:to_f)
    zip_name = "#{@client_name.downcase}_reports_#{@last_day}.zip"
    temp_zip = Tempfile.new([zip_name, '.zip'])
    cleanup = []

    begin
      Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip|
        @projects.each do |proj, weeks|
          next if @project_budgets[proj].zero?

          days_proposed = @project_budgets[proj]
          report = erb.result(binding)
          pdf = WickedPdf.new.pdf_from_string(report, { keep_temp: false })
          filename = "#{@client_name}_#{proj} Report.pdf"
          pdf_file = Tempfile.new([filename, '.pdf'])
          pdf_file.binmode
          pdf_file.write(pdf)
          cleanup << pdf_file
          zip.add(filename, pdf_file.path)
        end
      end
      zip_data = File.read(temp_zip.path)
      send_data(zip_data, type: 'application/zip', filename: zip_name)
    ensure
      temp_zip.close!
      cleanup.each(&:close!)
    end
  end

  private

  def report_params
    params.permit(:authenticity_token, :commit, :client, :date, :type, budgets: [])
  end
end
