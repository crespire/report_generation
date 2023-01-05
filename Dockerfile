# Specify base image
FROM ruby:3.0.2

# Add application code
ADD . /report-generation
WORKDIR /report-generation

# Install utilities
RUN apt-get update
RUN apt-get -y install cron
RUN apt-get -y install nano

# Add the cron job
RUN crontab -l | { cat; echo "0 0 * * 6 rake ds:update_clients"; } | crontab -

# Install depdendencies
RUN bundle install

# Precompile assets - only required for non-API apps
RUN rake assets:precompile

# Set up env
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

COPY ./bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Expose port
EXPOSE 3000

# Run server when container starts
CMD ["rails", "server", "-b", "0.0.0.0"]