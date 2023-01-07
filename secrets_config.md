# Rails Application Credentials
For the Rails application, whether in production or development, we must have a `master.key` available either through an environment secret (using `.env`) or through a file `config/master.key`. Rails will first check the environment for a key, and if it can't find one, will look for a config file.

When cloning the repository to a new machine, the easiest approach is to set a new `master.key` by running the command `EDITOR='code --wait' bin/rails credentials:edit`. This is because if Rails cannot find either an environment variable `RAILS_MASTER_KEY` or the file `config/master.key`, it will create a new `config/master.key` and encrypt the file using that new, generated key.

In short, if we want to use a previously generated `credentials.enc.yml` file, we must have that key available to decrypt the file. Otherwise, we can create a new `credentials.enc.yml` file so that we have the key locally to use.

## Required Additions
Inside the Rails app, the credentials file must have these fields added:
* `clockify` - API key for clockify authorization
* `workspace` - String for API in the format `workspaces/<workspace_id>`

# Docker Compose
In order to successfully package and run the application, the Rails application must have a master key available to decrypt the credentials.

We rely on having a `.env` file present to provide this key information. Because we specify a `RAILS_MASTER_KEY` via this file, our application does not need a `config/master.key` file, but if we have generated a new `credentials.enc.yml` file locally, then the `RAILS_MASTER_KEY` value must be updated inside the `.env` file to match.

`docker compose` is configured to grab these values from the environment to bake into the images without storing them inside the image contents. Because the resulting images depend on the build environment's secrets, we can change them as required.

In order to update the database configuration, we must clear the database volume which docker uses to persist data between runs. This means that any data in the database will be lost. In the case of DSReportBeaver, the data loss is minimal and simply means we will have to re-fetch the client list from Clockify, and users will have to re-enter project budgets after the database is recreated.

To clear the database:
1. Navigate to the project root directory
1. Stop any running containers using `docker compose stop`
1. Run `docker volume ls` to list the volumes
1. Run `docker volume rm <volume_name>` to remove the volume. The name should be `report_generation_postgres` if no docker configuration has been changed.
1. Upon application startup or build, Docker will recreate a new volume automatically.

## Required Additions
Inside the `.env` file, we require these three fields in order to build and deploy the application:
* `RAILS_MASTER_KEY` - this is the secret that allows Rails to decrypt all the other credentials. This value should be the contents of the `config/master.key` file used to encrypt the credentials.
* `POSTGRES_PASSWORD` - this can be an arbitrary value, but whatever is set becomes the password for the Postgres database user inside the `db` service container.
* `DATABASE_URL` - this value must be set in order for the web service to be able to communicate with the database service. The format is: `postgres://postgres:<chosen_password>@db:5432`. Using `docker compose`, the two containers will share a virtual network, so we can simply refer to the database service by its name `db` as set in the `docker-compose.yml` file.

# Putting the Two Together
There are two ways to manage the secrets to make sure everything works as expected.

1. The simplest way is to have a copy of the `.env` with the same master key that was used during development and staging.
1. Another way is to generate a new trust chain:
  1. Clone the Rails app repository
  1. Generate a new `config/master.key` by editing the encrypted credentials file to add the required additional fields as specified.
  1. Using the new `config/master.key`, generate a new `.env` file with the `RAILS_MASTER_KEY` along with the two database related values required.

The main takeaway is that the value of `RAILS_MASTER_KEY` in the `.env` file _must_ match the key that generated the `credentials.enc.yml`.

**Be certain that the `.env` file and/or the `config/master.key` files are not checked into version control, as both contain, in plain text, the decryption key.**
