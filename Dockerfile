FROM ruby:2.7.1-buster

COPY entrypoint.sh /entrypoint.sh
COPY action.yml /action.yml
COPY src /src

ENTRYPOINT ["/entrypoint.sh"]
