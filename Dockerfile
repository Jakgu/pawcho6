#====================STAGE 1====================
FROM scratch AS stage1
ADD alpine-minirootfs-3.21.3-x86_64.tar /

RUN apk add --update nodejs npm && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/app

COPY ./package.json ./

RUN npm install

COPY ./index.js ./

#====================STAGE 2====================
FROM nginx:alpine

RUN apk add --update nodejs curl && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/share/nginx/html

COPY --from=stage1 /usr/app ./

COPY ./default.conf /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=15s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

ARG VERSION
ENV APP_VERSION=${VERSION:-v1.0a}

EXPOSE 80

CMD ["/entrypoint.sh"]