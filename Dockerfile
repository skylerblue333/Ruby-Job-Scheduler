FROM ruby:3.3-alpine
WORKDIR /app
COPY lib ./lib
COPY bin ./bin
RUN addgroup -S sky && adduser -S -G sky sky && chmod +x /app/bin/sky-schedule
USER sky
CMD ["ruby", "bin/sky-schedule"]
