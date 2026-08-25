FROM ruby:3.3-alpine

WORKDIR /app
COPY lib ./lib
COPY bin ./bin

RUN addgroup -S sky && adduser -S -G sky -u 10001 sky \
    && chown -R sky:sky /app

USER 10001:10001
ENTRYPOINT ["ruby", "bin/sky-scheduler"]
