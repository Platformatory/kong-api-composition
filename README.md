# Overview

This plugin takes an array of HTTP request descriptions and provides a composite response containing a collection of individual responses. It can optionally flatten ("aggregate") response bodies to a single concatenated body with a configurable separator.

# Use-cases

The API gateway can function as a declarative composition engine enabling gateway operators to mash up responses from multiple HTTP sources. This saves the pains and pitfalls of having to write backend services (and the code footprint thereof) that provides the composition logic (and/OR) chatty API/network calls to do this on the client side.

# How it works

The URIs are digested into the Kong lifecycle handler with composition performed in the access phase handler.

# Installation and Getting Started

To use this plugin, you can install it via Luarocks: ``` luarocks install kong-api-composition ```

For development and testing purposes, you can git clone this repository and run ``` pongo run ``` to run tests or ```docker-compose up``` to spin up a self contained development environment.

# Usage

1. Configure a service and a route for the plugin: See declarative config in kong.yml for reference. You can also create this via Admin APIs. Check Kong docs for reference.
 
2. The Plugin accepts the following configurations:

| Parameter | Default  | Required | description |
| --------- | -------- | -------- | ----------- |
| config.destinations[] | | Yes | Array of destination inputs. Each takes the following parameters: URI, Method, Headers (key:value pairs) and Body (string) |
| Flattened | False | No | If enabled, flattens the response to a single body merging all response bodies instead of a collection of response headers and bodies |
| Separator | \| | No | If Flattened = True, Then this separator is used to delimit multiple response bodies |

For diagnostic tests, run ./run_tests.sh. With flattened: True,

```
{
  "body": "|{\n  \"headers\": {\n    \"1\": \"Accept: application/json\", \n    \"2\": \"Movie: King Kong\", \n    \"Content-Length\": \"1\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\", \n    \"X-Amzn-Trace-Id\": \"Root=1-604786d0-2b5cc8f2460f41d221b14e1b\"\n  }\n}\n|{\n  \"origin\": \"35.184.82.42\"\n}\n|{\n  \"user-agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\"\n}\n|{\n  \"args\": {}, \n  \"data\": \"{foo: bar}\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"1\": \"Accept: application/json\", \n    \"Content-Length\": \"10\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\", \n    \"X-Amzn-Trace-Id\": \"Root=1-604786d0-445f14f36504693719c92f5c\"\n  }, \n  \"json\": null, \n  \"origin\": \"35.184.82.42\", \n  \"url\": \"http://httpbin.org/post\"\n}\n|{\n  \"args\": {}, \n  \"data\": \"{bar: baz}\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"1\": \"Accept: application/json\", \n    \"Content-Length\": \"10\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\", \n    \"X-Amzn-Trace-Id\": \"Root=1-604786d0-064a2b857710109b1107cf43\"\n  }, \n  \"json\": null, \n  \"origin\": \"35.184.82.42\", \n  \"url\": \"http://httpbin.org/put\"\n}\n"
}
```

With flattened: False,
```
[
  {
    "body": "{\n  \"headers\": {\n    \"1\": \"Accept: application/json\", \n    \"2\": \"Movie: King Kong\", \n    \"Content-Length\": \"1\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\", \n    \"X-Amzn-Trace-Id\": \"Root=1-60478573-3b215e6d69fb1d38490e48b9\"\n  }\n}\n",
    "headers": {
      "Access-Control-Allow-Credentials": "true",
      "Content-Length": "275",
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      "Date": "Tue, 09 Mar 2021 14:25:55 GMT",
      "Server": "gunicorn/19.9.0",
      "Connection": "keep-alive"
    },
    "uri": "http://httpbin.org/headers",
    "status": 200
  },
  {
    "body": "{\n  \"origin\": \"35.184.82.42\"\n}\n",
    "headers": {
      "Access-Control-Allow-Credentials": "true",
      "Content-Length": "31",
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      "Date": "Tue, 09 Mar 2021 14:25:56 GMT",
      "Server": "gunicorn/19.9.0",
      "Connection": "keep-alive"
    },
    "uri": "http://httpbin.org/ip",
    "status": 200
  },
  {
    "body": "{\n  \"user-agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\"\n}\n",
    "headers": {
      "Access-Control-Allow-Credentials": "true",
      "Content-Length": "62",
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      "Date": "Tue, 09 Mar 2021 14:25:56 GMT",
      "Server": "gunicorn/19.9.0",
      "Connection": "keep-alive"
    },
    "uri": "http://httpbin.org/user-agent",
    "status": 200
  },
  {
    "body": "{\n  \"args\": {}, \n  \"data\": \"{foo: bar}\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"1\": \"Accept: application/json\", \n    \"Content-Length\": \"10\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\", \n    \"X-Amzn-Trace-Id\": \"Root=1-60478574-179143c45a7e3f9935cbe976\"\n  }, \n  \"json\": null, \n  \"origin\": \"35.184.82.42\", \n  \"url\": \"http://httpbin.org/post\"\n}\n",
    "headers": {
      "Access-Control-Allow-Credentials": "true",
      "Content-Length": "400",
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      "Date": "Tue, 09 Mar 2021 14:25:56 GMT",
      "Server": "gunicorn/19.9.0",
      "Connection": "keep-alive"
    },
    "uri": "http://httpbin.org/post",
    "status": 200
  },
  {
    "body": "{\n  \"args\": {}, \n  \"data\": \"{bar: baz}\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"1\": \"Accept: application/json\", \n    \"Content-Length\": \"10\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\", \n    \"X-Amzn-Trace-Id\": \"Root=1-60478574-4778ce1e3b1c66090e91f289\"\n  }, \n  \"json\": null, \n  \"origin\": \"35.184.82.42\", \n  \"url\": \"http://httpbin.org/put\"\n}\n",
    "headers": {
      "Access-Control-Allow-Credentials": "true",
      "Content-Length": "399",
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      "Date": "Tue, 09 Mar 2021 14:25:56 GMT",
      "Server": "gunicorn/19.9.0",
      "Connection": "keep-alive"
    },
    "uri": "http://httpbin.org/put",
    "status": 200
  }
]

```


# Known issues, Suggested Improvements & TODOs

1. Named option configurations for the HTTP client - such as keepalives, timeouts, SSL/TLS settings etc. This plugin uses Resty.HTTP. We can improve the options object to consume a named list of configuration flags that can be passed on to resty under the hood.

2. HTTP requests can be pipelined on an existing connection if sources are on the same host. See Resty request_pipeline. We can also explore potentially light threads (ngx.thread.spawn)

3. Aggregation is presently not "Accept" aware (both on the proxy side and the upstream source side): It naively sends JSON encoded responses.
  a. Need to flush out caveats around aggregation. Presently it is based on string concat with a configurable separator. For clarity, we refer to this as the "flatten" flag
