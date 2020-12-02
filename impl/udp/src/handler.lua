local BaseObfuscatedLog = require "kong.plugins.obfuscated-log-udp.base"

local plugin_name = "obfuscated-log-udp"
local LOG_TAG = "[" .. plugin_name .. "] "

local timer_at = ngx.timer.at
local udp = ngx.socket.udp

local ObfuscatedLogUdpHandler = BaseObfuscatedLog:extend{}

ObfuscatedLogUdpHandler.PRIORITY = 8
ObfuscatedLogUdpHandler.VERSION = "1.0.0"

local function log(premature, conf, str)
  if premature then
    return
  end

  local sock = udp()
  sock:settimeout(conf.timeout)

  local ok, err = sock:setpeername(conf.host, conf.port)
  if not ok then
    ngx.log(ngx.ERR, LOG_TAG, "could not connect to ", conf.host, ":", conf.port, ": ", err)
    return
  end

  ok, err = sock:send(str)
  if not ok then
    ngx.log(ngx.ERR, LOG_TAG, "could not send data to ", conf.host, ":", conf.port, ": ", err)
  else
    ngx.log(ngx.DEBUG, LOG_TAG, "sent: ", str)
  end

  ok, err = sock:close()
  if not ok then
    ngx.log(ngx.ERR, LOG_TAG, "could not close ", conf.host, ":", conf.port, ": ", err)
  end
end

function ObfuscatedLogUdpHandler:new()
  ObfuscatedLogUdpHandler.super.new(self, plugin_name)  
end

function ObfuscatedLogUdpHandler:log(conf)
  local ok, err = timer_at(0, log, conf, self:encode_ngx())
  if not ok then
    ngx.log(ngx.ERR, LOG_TAG, "could not create timer: ", err)
  end
end

return ObfuscatedLogUdpHandler
