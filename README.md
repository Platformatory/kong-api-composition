# Overview

This plugin takes a stringified JSON array of HTTP request objects and provides a composite response containing a collection of individual responses. It can optionally flatten ("aggregate") response bodies to a single concatenated body with an chosen separator.

# Use-cases

The API gateway can function as a declarative composition engine enabling gateway operators to mash up responses from multiple HTTP sources. This saves the pains and pitfalls of having to write backend services (and the code footprint thereof) that provides the composition logic (and/OR) chatty API/network calls to do this on the client side.

# How it works

The URIs are digested into the Kong lifecycle handler with composition performed in the access phase handler.

# Usage

1. Configure a service and a route for the plugin: See declarative config in kong.yml (/route/42)
2. Destinations accepts an array of JSON objects in the following format

[{
"uri": <some uri>,
"method": <any HTTP method>
"headers": <k/v literals of HTTP headers. Configure Accept: Application/JSON for best results>,
"body":  <request body>
}]

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

1. Configuration schema: Accept a YAML array of objects/sequences and validate it for sanity. Presently, this plugin consumes a JSON string (which can get unwieldy)
  a. JSON needs better validation
  b. May behave in unpredictable ways with quoted strings

2. Named option configurations for the HTTP client - such as keepalives, timeouts, SSL/TLS settings etc. This plugin uses Resty.HTTP. We can improve the options object to consume a named list of configuration flags that can be passed on to resty under the hood.

3. HTTP requests can be pipelined on an existing connection if sources are on the same host. See Resty request_pipeline. We can also explore potentially light threads (ngx.thread.spawn)

4. Aggregation is presently not "Accept" aware (both on the proxy side and the upstream source side): It naively sends JSON encoded responses.
  a. Need to flush out caveats around aggregation. Presently it is based on string concat with a configurable separator. For clarity, we refer to this as the flatten flag

5. Pongo tests and Lurarocks distribution (TBD)

