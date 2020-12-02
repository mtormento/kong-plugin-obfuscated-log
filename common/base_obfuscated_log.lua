local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"

local LOG_TAG = "[base-obfuscated-log] "

local BaseObfuscatedLog = BasePlugin:extend{}

local function is_json_body(content_type)
  return content_type and string.find(string.lower(content_type), "application/json", nil, true)
end

function BaseObfuscatedLog:new(name)
  BaseObfuscatedLog.super.new(self, name)

  self._obfuscator = require ("kong.plugins." .. name .. ".obfuscator")
  self._serializer = require ("kong.plugins." .. name .. ".serializer")
end

function BaseObfuscatedLog:access(conf)
  BaseObfuscatedLog.super.access(self)  

  local content_type = kong.request.get_header("Content-Type")
  -- ngx.log(ngx.DEBUG, LOG_TAG, "request content-type is: ", content_type)
  if is_json_body(content_type) then
    ngx.req.read_body()
    local body_data = ngx.req.get_body_data()
    -- ngx.log(ngx.DEBUG, LOG_TAG, "req_body is: ", body_data)
    if body_data ~= nil then
      ngx.ctx.req_body = self:handle_data(body_data, conf.obfuscate_request_body, conf.keys_to_obfuscate, conf.mask, conf.original_body_on_error)
--      ngx.log(ngx.DEBUG, LOG_TAG, "final request body is: ", cjson.encode(ngx.ctx.req_body))
    else
      ngx.ctx.req_body = {
        obfuscatedUdpLog = { 
          noBody = true
        }
      }
    end
  else
    ngx.ctx.req_body = {
      obfuscatedUdpLog = { 
        notJson = true
      }
    }
  end
end

function BaseObfuscatedLog:header_filter(conf)
  BaseObfuscatedLog.super.header_filter(self)  

  local content_type = kong.response.get_header('Content-Type')
  -- ngx.log(ngx.DEBUG, LOG_TAG, "response content-type is: ", content_type)
  if is_json_body(content_type) then
    -- Placeholder in case body_filter is not invoked because there's no body
    ngx.ctx.resp_body = {
      obfuscatedUdpLog = { 
        noBody = true
      }
    }
  else
    ngx.ctx.resp_body = {
      obfuscatedUdpLog = { 
        notJson = true
      }
    }
  end
end

function BaseObfuscatedLog:body_filter(conf)
  BaseObfuscatedLog.super.body_filter(self)  

  if not ngx.ctx.resp_body.obfuscatedUdpLog.notJson then
    local chunk = ngx.arg[1]
    local eof = ngx.arg[2]
    ngx.ctx.buffered = (ngx.ctx.buffered or "") .. chunk
    if eof then
      -- ngx.log(ngx.DEBUG, LOG_TAG, "resp_body is: ", ngx.ctx.buffered)
      if ngx.ctx.buffered ~= "" then
        ngx.ctx.resp_body = self:handle_data(ngx.ctx.buffered, conf.obfuscate_response_body, conf.keys_to_obfuscate, conf.mask, conf.original_body_on_error)
        ngx.ctx.buffered = nil
--        ngx.log(ngx.DEBUG, LOG_TAG, "final response body is: ", cjson.encode(ngx.ctx.resp_body))
      else
        ngx.ctx.resp_body = {
          obfuscatedUdpLog = { 
            errorCode = "BODY_EXPECTED_ERROR",
            errorMsg = "Body was expected, but not found."
          }
        }
        ngx.log(ngx.WARN, LOG_TAG, "Response body was expected, but not found.")
      end
    end
  end
end

function BaseObfuscatedLog:handle_data(data, obfuscate, keys_to_obfuscate, mask, original_body_on_error)
  local value, status
  if obfuscate and #keys_to_obfuscate > 0 then
    status, value = pcall(self._obfuscator.obfuscate_return_table, data, keys_to_obfuscate, mask)
  else
    status, value = pcall(cjson.decode, data)
  end
  if status then
    return value
  else
    ngx.log(ngx.ERR, LOG_TAG, "could not decode json: ", value)
    return {
      obfuscatedUdpLog = { 
        errorCode = "DECODE_ERROR",
        errorMsg = value,
        originalBody = original_body_on_error and data or "original_body_on_error is disabled"
      }
    }
  end
end

function BaseObfuscatedLog:encode_ngx()
  local data = self._serializer.serialize(ngx)
  local status, value = pcall(cjson.encode, data)
  if status then
    return value
  else
    ngx.log(ngx.ERR, LOG_TAG, "could not encode to json: ", value)
    return cjson.encode({
      obfuscatedUdpLog = { 
        errorCode = "ENCODE_ERROR",
        errorMsg = value,
        originalData = data
      }
    })
  end
end

return BaseObfuscatedLog
