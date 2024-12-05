FROM ruby:3.2.1

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /abwell
COPY Gemfile /abwell/Gemfile
COPY Gemfile.lock /abwell/Gemfile.lock
RUN gem update --system
RUN gem install bundler -v 2.5.18
RUN bundle install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
