FROM ruby:3.1.2-alpine3.16

ENV LANG=C.UTF-8 \
  TZ=Asia/Tokyo

ARG GOOGLE_KEY_JSON
RUN apk --no-cache add \
  build-base \
  mariadb-dev \
  bash \
  nodejs \
  yarn \
  tzdata \
  mysql-client

WORKDIR /app
RUN mkdir -p tmp/pids
RUN mkdir -p tmp/sockets
COPY Gemfile* ./
RUN bundle config set force_ruby_platform true
RUN bundle install -j4

COPY . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# 以下の記述があることでnginxから見ることができる
VOLUME /app/public
VOLUME /app/tmp

CMD bash -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"
