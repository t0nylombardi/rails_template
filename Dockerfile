FROM ruby:3.2.1-bullseye
# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y \
  build-essential \
  nano \
  nodejs

# Sets the path where the app is going to be installed
ENV RAILS_ROOT /var/www/

# Creates the directory and all the parents (if they don't exist)
RUN mkdir -p $RAILS_ROOT

# This is given by the Ruby Image.
# This will be the de-facto directory that 
# all the contents are going to be stored. 
WORKDIR $RAILS_ROOT
# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.

COPY Gemfile* ./
COPY Gemfile.lock ./

RUN gem install bundler -v 2.3.22 && bundle install --jobs 20 --retry 5
RUN gem install foreman

COPY . .
RUN rm -rf tmp/*
ADD . /var/www/