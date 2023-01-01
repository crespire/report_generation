# Report Generation

Application takes input and generates a ZIP file of PDFs or an XLSX sheet.

# Deployment
1. Install Ruby 3.0.2
1. Clone this repository
1. Run `bundle install` to install the dependencies
1. Once Rails is installed, set up the database by running `rails db:create; rails db:migrate`
1. Once the database is up to date, run `rake ds:update_clients` to populate the database for use
1. Run `EDITOR='code --wait' bin/rails credentials:edit` and make sure to add the following fields:
    * `http_name` - HTTP auth username
    * `http_pass` - HTTP auth password
    * `clockify` - API key for clockify authorization
    * `workspace` - String for API in the format `workspaces/<workspace_id>`
    * Upon closing this file, Rails will encrypt it with the `master.key`. Be sure to add the contents of `master.key` to the app's runtime environment under the variable name `RAILS_MASTER_KEY`.