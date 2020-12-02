local BaseObfuscatedLog = require "kong.plugins.obfuscated-log-file.base"

local plugin_name = "obfuscated-log-file"
local LOG_TAG = "[" .. plugin_name .. "] "

local timer_at = ngx.timer.at

local ObfuscatedLogFileHandler = BaseObfuscatedLog:extend{}

ObfuscatedLogFileHandler.PRIORITY = 9
ObfuscatedLogFileHandler.VERSION = "1.0.0"

local ffi = require "ffi"
local system_constants = require "lua_system_constants"

local O_CREAT = system_constants.O_CREAT()
local O_WRONLY = system_constants.O_WRONLY()
local O_APPEND = system_constants.O_APPEND()
local S_IRUSR = system_constants.S_IRUSR()
local S_IWUSR = system_constants.S_IWUSR()
local S_IRGRP = system_constants.S_IRGRP()
local S_IROTH = system_constants.S_IROTH()

local oflags = bit.bor(O_WRONLY, O_CREAT, O_APPEND)

local mode = bit.bor(S_IRUSR, S_IWUSR, S_IRGRP, S_IROTH)

local C = ffi.C

ffi.cdef[[
int write(int fd, const void * ptr, int numbytes);
]]

-- fd tracking utility functions
local file_descriptors = {}

local function log(premature, conf, message)
  if premature then
    return
  end

  local msg = message .. "\n"

  local fd = file_descriptors[conf.path]

  if fd and conf.reopen then
    -- close fd, we do this here, to make sure a previously cached fd also
    -- gets closed upon dynamic changes of the configuration
    C.close(fd)
    file_descriptors[conf.path] = nil
    fd = nil
  end

  if not fd then
    fd = C.open(conf.path, oflags, mode)
    if fd < 0 then
      local errno = ffi.errno()
      ngx.log(ngx.ERR, LOG_TAG, "failed to open the file: ", ffi.string(C.strerror(errno)))
    else
      file_descriptors[conf.path] = fd
    end
  end

  C.write(fd, msg, #msg)
end

function ObfuscatedLogFileHandler:new()
  ObfuscatedLogFileHandler.super.new(self, plugin_name)  
end

function ObfuscatedLogFileHandler:log(conf)
  local ok, err = timer_at(0, log, conf, self:encode_ngx())
  if not ok then
    ngx.log(ngx.ERR, LOG_TAG, "could not create timer: ", err)
  end
end

return ObfuscatedLogFileHandler
