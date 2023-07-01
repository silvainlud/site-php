FROM node:16-alpine as yarn_builder

ENV NODE_ENV=production
WORKDIR /app

ADD package.json yarn.lock webpack.config.js ./
ADD assets ./assets

RUN mkdir -p public && \
    NODE_ENV=development yarn install && \
    yarn run build

FROM ghcr.io/aeroclub-de-saint-omer/php:latest as php_builder

ENV APP_ENV=prod
WORKDIR /app

COPY . /app
RUN composer install

FROM ghcr.io/aeroclub-de-saint-omer/php:latest

EXPOSE 9000
WORKDIR /app

ARG APP_VERSION=dev
ARG GIT_COMMIT=master

ENV APP_VERSION="${APP_VERSION}"
ENV GIT_COMMIT="${GIT_COMMIT}"

COPY ./bin /app/bin
COPY ./config /app/config
COPY ./migrations /app/migrations
COPY ./public /app/public
COPY ./src /app/src
COPY ./tests /app/tests
COPY ./translations /app/translations
COPY ./.env /app
COPY ./composer* /app
COPY --from=yarn_builder /app/public/build /app/public/build
COPY --from=php_builder /app/vendor /app/vendor