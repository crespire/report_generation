# Report Generation

Application takes input and generates a ZIP file of PDFs or an XLSX sheet.

# Production Deployment
This project is set up to deploy in production via `docker compose` and assumes docker engine version 20.10.22.

For more details on how the application's credentials and secrets work, please consult `secrets_config.md`.

1. Clone this repository to the deployment machine
1. Navigate to the project directory where `Dockerfile` is located
1. Because we don't version control environment secrets, we must create a `.env` file at the root of the project directory in order to build and deploy the application. The `.env` file must contain three entries:
   * `RAILS_MASTER_KEY` - this is the secret that allows Rails to decrypt all the other credentials. The `config/master.key` file used to encrypt the credentials is the one that should be included.
   * `POSTGRES_PASSWORD` - this can be an arbitrary value, but whatever is set becomes the password for the Postgres database.
   * `DATABASE_URL` - this value must be set in order for the web service to be able to connect successfully to the database service. The format is: `postgres://postgres:<chosen_password>@db:5432` - because the two containers will share a virtual network, we can simply refer to the database container by its service name `db` as set in the `docker-compose.yml` file.
1. If there are any code changes or this is the initial deployment on a new machine, run `docker compose build` to (re)build the images required for the application.
1. Run `docker compose up -d` to deploy the application.
   * This will run two containers in the background: `web` and `db` which host, respectively the Rails application and the database. The `-d` flag runs the containers in detached mode which keeps the containers active in the background.
   * The `db` container uses a docker volume to persist data between reboots.
   * To check logs, navigate to the project directory and run `docker compose logs web`. This will show the logs for the web service. This is likely where most errors will come from, but you can substitute `web` with `db` to get the logs for the database service as well.
   * The `web` container has a few additional utility rake tasks set up to ease administration. In order to run these tasks, append `docker compose run web` before the command to run them in the web container.
      * `rake ds:reset_budgets` will run the rake task that clears all stored project budgets.
      * `rake ds:update_clients` will run the rake task that sync with Clockify to get a list of all clients. By design, this task will always run on container start, or when any other command is sent to the container.
      * The `web` container is also set up to run a cron job every Saturday to run `rake ds:update_clients`.

# Development Deployment
This project uses Ruby, Rails and PostgreSQL for its database.
1. Install Ruby 3.0.2 (recommend installing via a tool like `rbenv`)
1. Install PostgreSQL
1. Clone this repository
1. Run `bundle install` to install the dependencies
1. Once Rails is installed, set up the database by running `rails db:create; rails db:migrate`
1. Once the database is up to date, run `rake ds:update_clients` to populate the database for use
1. Run `EDITOR='code --wait' bin/rails credentials:edit` and make sure to add the following fields:
   * `clockify` - API key for clockify authorization
   * `workspace` - String for API in the format `workspaces/<workspace_id>`
1. Once the credentials file is saved, Rails will encrypt it. It is now safe to check in to version control. For more details about secrets management for this application, please see `secrets_config.md`.
1. Once the application is set up, `rails s` will start the server - when run locally, it will run in development mode and show errors in the browser.