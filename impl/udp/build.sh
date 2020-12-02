#!/bin/sh

sudo luarocks make kong-plugin-obfuscated-log-udp-1.0.0-1.rockspec
luarocks pack kong-plugin-obfuscated-log-udp
