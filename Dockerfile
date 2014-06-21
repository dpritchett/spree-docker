# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
#FROM phusion/passenger-full:<VERSION>
# Or, instead of the 'full' variant, use one of these:

FROM phusion/passenger-ruby21:0.9.10

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# If you're using the 'customizable' variant, you need to explicitly opt-in
# for features. Uncomment the features you want:
#
#   Build system and git.
#RUN /build/utilities.sh
#   Ruby support.
#RUN /build/ruby1.9.sh
#RUN /build/ruby2.0.sh
#RUN /build/ruby2.1.sh
#   Common development headers necessary for many Ruby gems,
#   e.g. libxml for Nokogiri.
#RUN /build/devheaders.sh

# ...put your own build instructions here...
RUN apt-get update

RUN apt-get -y install tmux

# base spree requests all three databases for testing :P
# client gems require the dev packages to compile
RUN apt-get -y install postgresql memcached libpq-dev
RUN apt-get -y install libmysqlclient-dev mysql-server
RUN apt-get -y install libsqlite3-dev sqlite3

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install spree
USER app
WORKDIR /home/app
RUN git clone https://github.com/spree/spree.git

WORKDIR /home/app/spree
RUN bundle install --path vendor/bundle
RUN bundle exec rake sandbox
WORKDIR /home/app/spree/sandbox
RUN bundle install --path vendor/bundle

# stuff
USER root
RUN rm -f /etc/service/nginx/down

ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
