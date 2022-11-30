-- handler.lua
local plugin = {
    PRIORITY = 1,
    VERSION = "0.1",
  }

-----------------------------------------------------------------------------------------------
-- Extract client_id value from claim (authorization_context) in the Payload of JWT
-- x_jwt_assertion is a classic JWT with 3 parts, separated by a dot: Header.Payload.Signature
-----------------------------------------------------------------------------------------------
local function extract_client_id (jwt)
    -- Get 1st . (dot)
    local b4, e4 = string.find(jwt, "%.")
    local b5, e5
    -- Get 2nd . (dot)
    if e4 ~= nil then
      b5, e5 = string.find(jwt, "%.", e4 + 1)
    end
    -- If we failed to find JWT payload
    if e4 == nil or e5 == nil then
      kong.log.err ( "Failure to extract payload from JWT")
      return ""
    end
    
    local jwt_payload = string.sub(jwt, e4 + 1, e5 - 1)
    
    -- base64 decoding of JWT payload
    local decode_base64 = ngx.decode_base64
    local decoded = decode_base64(jwt_payload)
    local cjson = require("cjson.safe").new()
    local jwt_json, err = cjson.decode(decoded)
    if jwt_json == nil then
        kong.log.err ( "Failure to decode and parse JSON of JWT payload")
        return ""
    end
    kong.log.notice("client_id: " .. jwt_json.authorization_context.client_id)

    return jwt_json.authorization_context["client_id"]
end

---------------------------------------------------------------------------------------------------
-- Executed for every request from a client and before it is being proxied to the upstream service
---------------------------------------------------------------------------------------------------
function plugin:access(plugin_conf)

    -- Get Authorization header to have Bearer value (i.e. JWT)
    local authorization = kong.request.get_header("Authorization")
    local jwt
    local client_id

    if authorization ~= nil then
        local b1, e1 = string.find(authorization, "Bearer ")
        if b1 ~= nil then
            jwt = string.sub(authorization, e1 + 1, -1)
        end
    end

    -- If we found the JWT from header
    if jwt ~= nil then
        -- Extract client_id from JWT payload
        client_id = extract_client_id (jwt)    
    end

    if client_id == nil or client_id == "" then
        kong.log.err ( "Failure to get JWT from 'Authorization' header")
        return kong.response.exit(500, "{\
            \"Error Message\": \"Failure to get client_id from JWT\"\
            }",
            {
            ["Content-Type"] = "application/json"
            }
        )
    end

    -- load driver
    -- Documentation: http://lunarmodules.github.io/luasql/
    local driver = require "luasql.mysql"

    -- create environment object
    local env = assert (driver.mysql())

    -- connect to data source
    kong.log.notice("connect to MySQL: '" .. 
            plugin_conf.sourcename .. ", " ..
            plugin_conf.username   .. ", " ..
            plugin_conf.password   .. ", " ..
            plugin_conf.host       .. ", " ..
            plugin_conf.port       .. 
            "'")
    local con = assert (env:connect(plugin_conf.sourcename, plugin_conf.username, plugin_conf.password, plugin_conf.host,  plugin_conf.port))

    -- execute SQL query
    local query = "SELECT client_id, client_secret FROM clients WHERE client_id = '" .. client_id .. "'"
    kong.log.notice("SQL query: " .. query)    
    local cursor = con:execute(query)
    -- local row = cursor:fetch({})
    -- while row do
    --    kong.log.notice(row[1], row[2])
    --    row = cursor:fetch({})
    -- end
    local nb_rows = 0
    if cursor ~= nill then
        nb_rows = cursor:numrows()
    end

    -- close the cursor
    if cursor ~= nil then
        local rc = cursor:close()
        kong.log.notice("Close the MySQL cursor: " .. tostring(rc))
    end
    -- close the MySQL connection
    if con ~= nil then
        local rc = con:close()
        kong.log.notice("Close the MySQL connection: " .. tostring(rc))
    end
    -- close the environment MySQL object
    if env ~= nil then
        local rc = env:close()
        kong.log.notice("Close the environment MySQL object: " .. tostring(rc))
    end

    -- If we don't found the client_id in MySQL
    if nb_rows == 0 then
        kong.log.err ( "Failure to get client_id '" .. client_id .. "' in MySQL")
        return kong.response.exit(500, "{\
            \"Error Message\": \"Failure to get client_id in MySQL\"\
            }",
            {
            ["Content-Type"] = "application/json"
            }
        )

    end
    kong.log.notice("We found client_id '" .. client_id .. "' in MySQL")
end
  

return plugin