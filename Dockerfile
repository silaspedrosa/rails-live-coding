#    ____                  _             ____  _             _ _       
#   / ___|__ _ _ __  _   _| |__   __ _  / ___|| |_ _   _  __| (_) ___  
#  | |   / _` | '_ \| | | | '_ \ / _` | \___ \| __| | | |/ _` | |/ _ \ 
#  | |__| (_| | |_) | |_| | |_) | (_| |  ___) | |_| |_| | (_| | | (_) |
#   \____\__,_| .__/ \__, |_.__/ \__,_| |____/ \__|\__,_|\__,_|_|\___/ 
#             |_|    |___/                                             

#  contato@capyba.com
#  www.capyba.com

# Base our image on an official, minimal image of our preferred Ruby
FROM ruby:2.4.2-slim-stretch

MAINTAINER Diogo Caetano <diogo@implystudio.com>

# Install essential Linux packages
RUN apt-get clean
RUN apt-get update -qq
RUN apt-get install -y build-essential
RUN apt-get install -y libpq-dev default-libmysqlclient-dev libnotify-bin xosd-bin nano curl wget sudo memcached graphviz
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && sudo apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn

# Install image upload dependences
# RUN apt-get install -y imagemagick libmagickcore-dev libmagickwand-dev graphviz file
RUN apt-get install -y imagemagick graphviz file

#certificados openssl
RUN apt-get install -y openssl ca-certificates

# Define where our application will live inside the image
ENV RAILS_ROOT /app
RUN mkdir -p $RAILS_ROOT/tmp/pids
WORKDIR $RAILS_ROOT

# Expose port 80 to the Docker host, so we can access it, on dokku the nginx map this port from the outside.
EXPOSE 80

# Possible to run the nano command
ENV TERM xterm

# Allow unicode characters in the console
ENV LANG C.UTF-8

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler -v 2.0.1

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# Install Deps
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install 


# Copy the Rails application into place
COPY . .

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
# CMD ["/bin/bash"]
# CMD [ "config/containers/app_cmd.sh" ]

# Command to acess de vm
# docker exec -it railsbase_app_1 /bin/bash
