# Overview

This plugin takes an array of HTTP request descriptions and provides a composite response containing a collection of individual responses. It can optionally flatten ("aggregate") response bodies to a single concatenated body with an chosen separator.

# Use-cases

The API gateway can function as a declarative composition engine enabling gateway operators to mash up responses from multiple HTTP sources. This saves the pains and pitfalls of having to write backend services (and the code footprint thereof) that provides the composition logic (and/OR) chatty API/network calls to do this on the client side.

# How it works

The URIs are digested into the Kong lifecycle handler with composition performed in the access phase handler.

# Usage

1. Configure a service and a route for the plugin: See declarative config in kong.yml (/route/42)
2. An array of Destinations is accepted in the following format

```
uri: <some uri>
method: <any HTTP verb>
headers: Array of headers as strings in the format "key: value"
```

For diagnostic tests, run ./run_tests.sh. With flattened: True,

{
  "body": "{\n  \"args\": {}, \n  \"data\": \"\", \n  \"files\": {}, \n  \"form\": {}, \n  \"headers\": {\n    \"Content-Length\": \"0\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\", \n    \"X-Amzn-Trace-Id\": \"Root=1-60460580-5e142dd043972bc36fd4d6df\"\n  }, \n  \"json\": null, \n  \"method\": \"GET\", \n  \"origin\": \"35.184.82.42\", \n  \"url\": \"http://httpbin.org/anything\"\n}\n{\n  \"origin\": \"35.184.82.42\"\n}\n{\n  \"user-agent\": \"lua-resty-http/0.14 (Lua) ngx_lua/10017\"\n}\n"
}

With flattened: False,
[
  {
    "headers": {
      "Access-Control-Allow-Credentials": "true",
      "Content-Length": "375",
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      "Date": "Mon, 08 Mar 2021 11:11:13 GMT",
      "Server": "gunicorn/19.9.0",
      "Connection": "keep-alive"
    },
    "uri": "http://httpbin.org/anything",
    "status": 200
  },
  {
    "body": "{\n  \"origin\": \"35.184.82.42\"\n}\n",
    "headers": {
      "Access-Control-Allow-Credentials": "true",
      "Content-Length": "31",
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      "Date": "Mon, 08 Mar 2021 11:11:13 GMT",
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
      "Date": "Mon, 08 Mar 2021 11:11:14 GMT",
      "Server": "gunicorn/19.9.0",
      "Connection": "keep-alive"
    },
    "uri": "http://httpbin.org/user-agent",
    "status": 200
  }
]


4. Set HTTP client options (TODO: Under progress


# Known issues, Suggested Improvements & TODOs

1. Named option configurations for the HTTP client - such as keepalives, timeouts, SSL/TLS settings etc. This plugin uses Resty.HTTP. We can improve the options object to consume a named list of configuration flags that can be passed on to resty under the hood.

2. HTTP requests can be pipelined on an existing connection if sources are on the same host. See Resty request_pipeline. We can also explore potentially light threads (ngx.thread.spawn)

3. Aggregation is presently not "Accept" aware (both on the proxy side and the upstream source side): It naively sends JSON encoded responses.
  a. Need to flush out caveats around aggregation. Presently it is based on string concat with a configurable separator. For clarity, we refer to this as the flatten flag

4. Pongo tests and Lurarocks distribution (TBD)

