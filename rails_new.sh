#!/usr/bin/env bash

cd ChaTravel
bundle install --path vendor/bundle
bundle exec rails new ChatTravel -d mysql
bundle exec rake db:create
bundle exec rake db:migrate
