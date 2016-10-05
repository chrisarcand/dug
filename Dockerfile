FROM ruby:2.3.1
MAINTAINER Drew Bomhof (syncrou) https://github.com/syncrou

ENV APP_ROOT dug

RUN gem install dug --no-ri --no-rdoc

RUN mkdir ${APP_ROOT} && cd ${APP_ROOT}

COPY templates/dug_rules.yml ${APP_ROOT}

COPY templates/script.rb ${APP_ROOT}

CMD [ "ruby", "dug/script.rb" ]
