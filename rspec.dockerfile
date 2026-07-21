FROM ruby:3.3-alpine
LABEL maintainer="Kelvin Nwokike <knwokike@gmail.com>"

RUN apk add --no-cache build-base

WORKDIR /app

# Install gems from a pinned Gemfile for reproducible test runs.
COPY Gemfile Gemfile* ./
RUN gem install bundler && bundle install

COPY . .

ENTRYPOINT [ "bundle", "exec", "rspec" ]
