# Mock Server by [killgrave](https://github.com/friendsofgo/killgrave)

> The mock file should adhere to the `<name>.imp.json` format.

### Mock Specification

The imposter object can be divided in two parts:

* [Request](#request)
* [Response](#response)

#### Request

This part defines how Killgrave should determine whether an incoming request matches the imposter or not. The `request` object has the following properties:

* `method` (<span style="color:red">mandatory</span>): The [HTTP method](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods) of the incoming request.
* `endpoint` (<span style="color:red">mandatory</span>): Path of the endpoint relative to the base. Supports regex.
* `schemaFile`: A JSON schema to validate the incoming request against.
* `params`: Restrict incoming requests by query parameters. More info can be found [here](#create-an-imposter-with-query-params). Supports regex.
* `headers`: Restrict incoming requests by HTTP header. More info can be found [here](#create-an-imposter-with-headers).

#### Response

This part defines how Killgrave should respond to the incoming request. The `response` object has the following properties:

* `status` (<span style="color:red">mandatory</span>): Integer defining the HTTP status to return.
* `body` or `bodyFile`: The response body. Either a literal string (`body`) or a path to a file (`bodyFile`). `bodyFile` is especially useful in the case of large outputs.
This property is optional: if not response body should be returned it should be removed or left empty.
* `headers`: Headers to return in the response.
* `delay`: Time the server waits before responding. This can help simulate network issues, or high server load. Uses the [Go ParseDuration format](https://pkg.go.dev/time#ParseDuration). Also, you can specify minimum and maximum delays separated by ':'. The response delay will be chosen at random between these values. Default value is "0s" (no delay).

### Using regex in imposters

* [Using regex in the endpoint](#regex-on-the-endpoint)
* [Using regex in the query parameters](#regex-on-the-params)
* [Using regex in the headers](#regex-on-the-headers)

#### Regex in the endpoint

Killgrave uses the [gorilla/mux](https://github.com/gorilla/mux) regex format for endpoint regex matching.

In the next example, we have configured an endpoint to match with any kind of [ULID ID](https://cran.r-project.org/web/packages/ulid/vignettes/intro-to-ulid.html):

```json
[
  {
    "request": {
      "method": "GET",
      "endpoint": "/gophers/{_id:[\\w]{26}}"
    },
    "response": {
      "status": 200,
      "headers": {
        "Content-Type": "application/json"
      },
      "body": "{\"data\":{\"type\":\"gophers\",\"id\":\"01D8EMQ185CA8PRGE20DKZTGSR\",\"attributes\":{\"name\":\"Zebediah\",\"color\":\"Purples\",\"age\":55}}}"
    }
  }
]
```

#### Regex in the query parameters:

Killgrave uses the [gorilla/mux](https://github.com/gorilla/mux) regex format for query parameter regex matching.

In this example, we have configured an imposter that only matches if we receive an apiKey as query parameter:

```json
[
  {
    "request": {
      "method": "GET",
      "endpoint": "/gophers/{_id:[\\w]{26}}",
      "params": {
        "apiKey": "{_apiKey:[\\w]+}"
      }
    },
    "response": {
      "status": 200,
      "headers": {
        "Content-Type": "application/json"
      },
      "body": "{\"data\":{\"type\":\"gophers\",\"id\":\"01D8EMQ185CA8PRGE20DKZTGSR\",\"attributes\":{\"name\":\"Zebediah\",\"color\":\"Purples\",\"age\":55}}}"
    }
  }
]
```

#### Regex in the headers:

In this case we will not need the `gorilla mux nomenclature` to write our regex.

In the next example, we have configured an imposter that uses regex to match an Authorization header.

```json
[
  {
    "request": {
      "method": "GET",
      "endpoint": "/gophers/{id:[\\w]{26}}",
      "headers": {
        "Authorization": "\\w+"
      }
    },
    "response": {
      "status": 200,
      "headers": {
        "Content-Type": "application/json"
      },
      "body": "{\"data\":{\"type\":\"gophers\",\"id\":\"01D8EMQ185CA8PRGE20DKZTGSR\",\"attributes\":{\"name\":\"Zebediah\",\"color\":\"Purples\",\"age\":55}}}"
    }
  }
]
```

### Creating an imposter using JSON Schema

Sometimes, we need to validate our request more thoroughly. In cases like this we can
create an imposter that only matches with a valid [json schema](https://json-schema.org/).

To do that we will need to define our `json schema` first:

`imposters/schemas/create_gopher_request.json`

```json
{
    "type": "object",
    "properties": {
        "data": {
            "type": "object",
            "properties": {
                "type": {
                    "type": "string",
                    "enum": [
                        "gophers"
                    ]
                },
                "attributes": {
                    "type": "object",
                    "properties": {
                        "name": {
                            "type": "string"
                        },
                        "color": {
                            "type": "string"
                        },
                        "age": {
                            "type": "integer"
                        }
                    },
                    "required": [
                        "name",
                        "color",
                        "age"
                    ]
                }
            },
            "required": [
                "type",
                "attributes"
            ]
        }
    },
    "required": [
        "data"
    ]
}
```

With this `json schema`, we expect a `request` like this:

```json
{
    "data": {
        "type": "gophers",
        "attributes": {
            "name": "Zebediah",
            "color": "Purples",
            "age": 55
        }
    }
}
```

Then our imposter will be configured as follows:

````json
[
  {
    "request": {
        "method": "POST",
        "endpoint": "/gophers",
        "schemaFile": "schemas/create_gopher_request.json",
        "headers": {
            "Content-Type": "application/json"
        }
    },
    "response": {
        "status": 201,
        "headers": {
            "Content-Type": "application/json"
        }
    }
  }
]
````

The path where the schema is located is relative to where the imposters are.

### Creating an imposter with delay

If we want to simulate a problem with the network, or create a more realistic response, we can use the `delay` property.

The `delay` property can take duration in the [Go ParseDuration format](https://golang.org/pkg/time/#ParseDuration). The server response will be delayed by the specified duration.

Alternatively, the `delay` property can take a range of two durations, separated by a ':'. In this case, the server will respond with a random delay in this range.

For example, we can modify our previous POST call to add a `delay` to determine that we want our response to be delayed by 1 to 5 seconds:

````json
[
  {
    "request": {
        "method": "POST",
        "endpoint": "/gophers",
        "schemaFile": "schemas/create_gopher_request.json",
        "headers": {
            "Content-Type": "application/json"
        }
    },
    "response": {
        "status": 201,
        "headers": {
            "Content-Type": "application/json"
        },
        "delay": "1s:5s"
    }
  }
]
````

### Creating an imposter with dynamic responses

Killgrave allows dynamic responses. Using this feature, Killgrave can return different responses on the same endpoint.

To do this, all imposters need to be ordered from most restrictive to least. Killgrave tries to match the request with each of the imposters in sequence, stopping at the first imposter that matches the request.

In the following example, we have defined multiple imposters for the `POST /gophers` endpoint. Let's say an incoming request does not match the JSON schema specified in the first imposter's `schemaFile`. Therefore, Killgrave skips this imposter and tries to match the request against the second imposter. This imposter is much less restrictive, so the request matches and the associated response is returned.

````json
[
  {
    "request": {
        "method": "POST",
        "endpoint": "/gophers",
        "schemaFile": "schemas/create_gopher_request.json",
        "headers": {
            "Content-Type": "application/json"
        }
    },
    "response": {
        "status": 201,
        "headers": {
            "Content-Type": "application/json"
        }
    }
  },
  {
      "request": {
          "method": "POST",
          "endpoint": "/gophers"
      },
      "response": {
          "status": 400,
          "headers": {
              "Content-Type": "application/json"
          },
          "body": "{\"errors\":\"bad request\"}"
      }
  }
]
````
