#!/bin/bash -xv
bundle install
bundle exec jekyll serve --host 0.0.0.0 --port 4000
