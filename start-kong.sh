# Start MySQL 6.5
# docker run --detach --name=mysql --env="MYSQL_ROOT_PASSWORD=mypassword" --network=kong-net --publish 3306:3306 mysql
# 
# Connect to DB and populate the DB
# mysql -uroot -p -h 127.0.0.1 -P 3306
#    CREATE DATABASE clients CHARACTER SET utf8 COLLATE utf8_general_ci;
#    use clients;
#    CREATE TABLE clients (client_id varchar(255), client_secret varchar(255));
#    insert into clients values ("0901e65f1d3869b3a8e9e8492d46cc7bbf694df25aa1f0be83b30faa8babaf8f", "ABCDEFGHIJKL");
# 
# Create a route /httpbin and configure & apply the plugin
# http :8000/httpbin Authorization:' Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkNfY2ZhVGd3T25mTUhLdy1PaGs1VGtvWldfTTlVUV9DUW9GR1BDODFySFUifQ.eyJzdWIiOiIwOTAxZTY1ZjFkMzg2OWIzYThlOWU4NDkyZDQ2Y2M3YmJmNjk0ZGYyNWFhMWYwYmU4M2IzMGZhYThiYWJhZjhmIiwic2NvcGUiOiJvcGVuaWQiLCJpc3MiOiJzZGotZGV2dHUiLCJpYXQiOjE2Njg2MTI1NTAsImF1dGhvcml6YXRpb25fY29udGV4dCI6eyJjbGllbnRfaWQiOiIwOTAxZTY1ZjFkMzg2OWIzYThlOWU4NDkyZDQ2Y2M3YmJmNjk0ZGYyNWFhMWYwYmU4M2IzMGZhYThiYWJhZjhmIn0sImF1dGhfdGltZSI6MTY2ODYxMjU1MCwiZGF0Ijp7ImF1dGhlbnRpY2F0aW9uX2xldmVsIjoiMiJ9LCJleHAiOjE2Njg2MTUyNTAsImF1ZCI6WyJjYS1lc2IiXSwiQVNfSTAwMDFfdHlwZSI6ImNsaWVudF9jcmVkZW50aWFscyIsImp0aSI6IjY5N2I2MmFiLTdlNjUtNDAzMC04N2Y2LTJhMGM2NDc5MzcxNiIsImFjciI6IjIwIiwiYW1yIjpbInB3ZCJdfQ.J5jnqnGFw_lTHF5I45Hcb7nm8PNvF9ogTEtAMUz-Q_PnQCZek9g1hNL9bTisHke1ANIXGB_GOyRFUYxj6aui1ZLpfwDIr5KgTcM9YtgloQZU1I6hR6R7llD7YRsVKcmtca5uwpDcIJaW46lL-h4dKfS3AJXhTPGPgBMdo2OTsennU7FkNoOER7mrHTTRc6yhGm38NUYB0u8nbMqDzn_U423S-cPeWb-aeo-spero-UjU7PWwo_FhbqPNlafvYr_IPmVWP8PR0hfuEwPR0wq9I8L92G3ozsQMo5GJSRTTy8HmrwUmAI7Z_L4pAslKTDWiQ1Ql6p38kBvwZBx_nUxfxg'

# remove the previous container
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