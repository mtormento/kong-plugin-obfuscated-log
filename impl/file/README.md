# Kong Obfuscated File Logging

A Kong plugin that logs obfuscated request and response json bodies to file.

## Description

This plugin is useful when you want to log request and response json bodies but you need to mask sensitive data.

## Installation

### Development

Navigate to kong/plugins folder and clone this repo

<pre>
$ cd /path/to/kong/plugins
$ git clone https://github.com/mtormento/kong-plugin-obfuscated-log obfuscated-log
$ cd obfuscated-log/file
$ luarocks make *.rockspec
</pre>

To make Kong aware that it has to look for the obfuscated-log-udp plugin, you'll have to add it to the custom_plugins property in your configuration file.

<pre>
custom_plugins:
    - obfuscated-log-file
</pre>

Restart Kong and you're ready to go.

## luarocks

<pre>
$ luarocks install kong-plugin-obfuscated-log-file
</pre>

## Usage

### Parameters

| Parameter                              | Required | Default           | Description                                                                                                                                                                                                                                                                                                                                                                              |
| -------------------------------------- | -------- | ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name                                   | yes      |                   | The name of the plugin to use, in this case `obfuscated-log-file`.                                                                                                                                                                                                                                                                                                                              |
| service_id                             | semi     |                   | The id of the Service which this plugin will target.                                                                                                                                                                                                                                                                                                                                     |
| route_id                               | semi     |                   | The id of the Route which this plugin will target.                                                                                                                                                                                                                                                                                                                                       |
| enabled                                | no       | `true`            | Whether this plugin will be applied.                                                                                                                                                                                                                                                                                                                                                     |
| config.path                            | yes      |                   | Log file path.
| config.reopen                          | yes      | `false`           | Whether to reopen the log file.
| config.obfuscate_request_body          | yes      | `true`            | Whether to obfuscate request body.
| config.obfuscate_response_body         | yes      | `true`            | Whether to obfuscate response body.
| config.keys_to_obfuscate               | no       |                   | Set of keys to obfuscate.
| config.mask                            | yes      | `***`             | Mask to use for obfuscation.
| config.original_body_on_error          | yes      | `false`           | Whether to log original body on obfuscation error.

## Author
Marco Tormento

## License
<pre>
The MIT License (MIT)
=====================

Copyright (c) 2020 Marco Tormento

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
</pre>
