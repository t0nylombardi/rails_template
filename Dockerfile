FROM ruby:3.2.1-bullseye
# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y \
  build-essential \
  nano \
  nodejs \
  yarn

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
  apt-get install -y nodejs

ENV RAILS_ROOT /var/www/

RUN mkdir -p $RAILS_ROOT

WORKDIR $RAILS_ROOT

COPY Gemfile $RAILS_ROOT/Gemfile
COPY Gemfile.lock $RAILS_ROOT/Gemfile.lock

COPY package.json $RAILS_ROOT/package.json
COPY yarn.lock $RAILS_ROOT/yarn.lock


RUN gem install bundler -v 2.3.22 && bundle install --jobs 20 --retry 5
RUN gem install foreman
RUN yarn


RUN rm -rf tmp/*
EXPOSE 3000
ADD . /var/www/