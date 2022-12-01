# Start MySQL 6.5
# docker run --detach --name=mysql --env="MYSQL_ROOT_PASSWORD=mypassword" --network=kong-net --publish 3306:3306 mysql
# 
# Connect to DB and populate the DB
# mysql -uroot -p -h 127.0.0.1 -P 3306
#    CREATE DATABASE clients CHARACTER SET utf8 COLLATE utf8_general_ci;
#    use clients;
#    CREATE TABLE clients (client_id varchar(255), client_secret varchar(255));
#    insert into clients values ("1234567890", "ABCDEFGHIJKL");
# 
# Create a route /httpbin and configure & apply the plugin
# http :8000/httpbin Authorization:' Bearer <bearer-with-a-client_id-claim'

# Remove the previous container
docker rm -f kong-gateway-db-sql >/dev/null

docker run -d --name kong-gateway-db-sql \
--network=kong-net \
--link kong-database-db-sql:kong-database-db-sql \
--mount type=bind,source=/Users/jeromeg/Documents/Kong/Tips/kong-plugin-db-sql/kong/plugins/db-sql,destination=/usr/local/share/lua/5.1/kong/plugins/db-sql \
-e "KONG_DATABASE=postgres" \
-e "KONG_PG_HOST=kong-database-db-sql" \
-e "KONG_PG_USER=kong" \
-e "KONG_PG_PASSWORD=kongpass" \
-e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
-e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
-e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
-e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
-e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
-e "KONG_ADMIN_GUI_URL=http://localhost:8002" \
-e "KONG_PLUGINS=bundled,db-sql" \
-e KONG_LICENSE_DATA \
-p 8000:8000 \
-p 8443:8443 \
-p 8001:8001 \
-p 8002:8002 \
-p 8444:8444 \
kong-gateway-db-sql

echo "see logs 'docker logs kong-gateway-db-sql -f'"