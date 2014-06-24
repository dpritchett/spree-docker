# This Dockerfile builds Spree from master in a container and  sets up
# the 'sandbox' test app.
#
# From there you'll be able to run the test suite or a web server.
#
# Usage: 
# 
# $ docker build --tag="spree-master-local" .
# $ docker run -t -i spree-master-local tmux
#
# (From within the container)
# $ bundle exec rails c

############################################################
# BASE IMAGE
############################################################

FROM phusion/passenger-ruby21:0.9.10

############################################################
# ENVIRONMENT
############################################################

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]


############################################################
# PACKAGES
############################################################

RUN   apt-get update --fix-missing
RUN   apt-get -y install tmux # simplify interactive dev inside container

# base spree requests all three databases for testing :P
# client gems require the dev packages to compile
RUN   apt-get -y install postgresql     libpq-dev
RUN   apt-get -y install mysql-server   libmysqlclient-dev
RUN   apt-get -y install sqlite3        libsqlite3-dev
RUN   apt-get -y install memcached # why not?

# Clean up APT when done.
RUN   apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


############################################################
# APP + GEMS
############################################################

# install spree as non-privileged user
USER    app
WORKDIR /home/app
RUN     git clone https://github.com/spree/spree.git

WORKDIR /home/app/spree

# local artifacts for simpler permissions
RUN         bundle install --path vendor/bundle 
RUN bundle  exec rake sandbox
WORKDIR     /home/app/spree/sandbox
RUN         bundle install --path ../vendor/bundle # reuse the local bundle from above

# switch back to app user for interactive work
ENV HOME /home/app
