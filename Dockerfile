# docker build -t kong-gateway-db-sql .
FROM kong/kong-gateway:3.0.1.0-alpine
USER root

#RUN mkdir -p /usr/local/share/lua/5.1/kong/plugins/db-sql
#COPY /kong/plugins/db-sql/* /usr/local/share/lua/5.1/kong/plugins/db-sql/

RUN apk update && apk add git musl-dev libffi-dev gcc g++ file make
RUN apk add mariadb-dev
RUN luarocks install luasql-mysql MYSQL_INCDIR=/usr/include/mysql

# reset back the defaults
USER kong
ENTRYPOINT ["/docker-entrypoint.sh"]
STOPSIGNAL SIGQUIT
HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health
CMD ["kong", "docker-start"]
