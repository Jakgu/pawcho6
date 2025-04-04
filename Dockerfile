# syntax=docker/dockerfile:1

#====================STAGE 1====================
FROM scratch AS stage1
ADD alpine-minirootfs-3.21.3-x86_64.tar /

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --update --no-cache nodejs npm git openssh-client

# Konfiguracja SSH
RUN mkdir -p /root/.ssh && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

# Klonowanie repozytorium z wykorzystaniem SSH
RUN --mount=type=ssh \
    git clone git@github.com:Jakgu/pawcho6.git /usr/app && \
    rm -rf /usr/app/.git

WORKDIR /usr/app

RUN npm install


#====================STAGE 2====================
FROM nginx:alpine

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --update --no-cache nodejs curl

WORKDIR /usr/share/nginx/html

COPY --from=stage1 /usr/app ./

COPY ./default.conf /etc/nginx/conf.d/default.conf

RUN mv entrypoint.sh /entrypoint.sh && \
    chmod +x /entrypoint.sh

HEALTHCHECK --interval=15s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

ARG VERSION
ENV APP_VERSION=${VERSION:-v1.0a}

LABEL org.opencontainers.image.source="https://github.com/Jakgu/pawcho6" \
      org.opencontainers.image.description="Simple nodejs app" \
      org.opencontainers.image.authors="Jakgu"

EXPOSE 80

CMD ["/entrypoint.sh"]
