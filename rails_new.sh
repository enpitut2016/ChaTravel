#!/usr/bin/env bash

cd ChaTravel
bundle install --path vendor/bundle
bundle exec rake db:create
bundle exec rake db:migrate
