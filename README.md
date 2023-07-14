BrAPI.R
=======

This R package contains a simple R6 Class for interacting with a BrAPI server.  It holds all of the information needed to connect to a server (such as the hostname) and has helper functions for making an HTTP requests to the BrAPI server.

It does not have any knowledge of the currently supported BrAPI endpoints.  You'll need to refer to the [BrAPI specification](https://brapi.org/specification) to know which endpoints to use and how the response will be formatted.

```R
# Get a BrAPI Connection
> wheat <- getBrAPIConnection("T3/Wheat")

# Get Studies associated with the Cornell breeding program
> resp <- wheat$get("/studies", query=list(programName="Cornell University"), pageSize=1000)
> studies <- resp$data
 
# Get all Germplasm stored in the database
> resp <- wheat$get("/germplasm", page="all", pageSize=5000)
> germplasm <- resp$combined_data
```

## Installation

This package can be installed directly from GitHub, using the `devtools` package.

```R
# Install devtools, if you haven't already
install.packages("devtools")

# Install the BrAPI package from GitHub
library(devtools)
install_github("TriticeaeToolbox/BrAPI.R")
library(BrAPI)
```

## Documentation

Reference Documentation can be found here: [https://triticeaetoolbox.github.io/BrAPI.R](https://triticeaetoolbox.github.io/BrAPI.R)


## Creating a BrAPI Connection

The [BrAPIConnection Class](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html) contains information about the BrAPI server and has helper functions for making HTTP requests.

There are some known pre-configured BrAPI connections included with this package.  To see the list of known BrAPI connections, use the [listBrAPIConnections() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/listBrAPIConnections.html):

```R
> listBrAPIConnections()
Known BrAPI Connections:
 T3/Wheat = wheat.triticeaetoolbox.org [v2]
 T3/Wheat Sandbox = wheat-sandbox.triticeaetoolbox.org [v2]
 T3/Oat = oat.triticeaetoolbox.org [v2]
 T3/Oat Sandbox = oat-sandbox.triticeaetoolbox.org [v2]
 T3/Barley = barley.triticeaetoolbox.org [v2]
 T3/Barley Sandbox = barley-sandbox.triticeaetoolbox.org [v2]
 Cassavabase = cassavabase.org [v2]
```

To use a known BrAPI connection, reference it by name in the [getBrAPIConnection() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/getBrAPIConnection.html):
```R
> wheat <- getBrAPIConnection("T3/Wheat")
```

To manually create a BrAPI connection, you'll need to specify the host of the BrAPI server (and optionally set the protocol, path, and/or version) in the [createBrAPIConnection() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html):

```R
> kelp <- createBrAPIConnection("sugarkelpbase.org")
> kelpv1 <- createBrAPIConnection("sugarkelpbase.org", version="v1")
```

## Making HTTP Requests

Once you have a `BrAPIConnection` object, you can use it to make HTTP Requests to the BrAPI server.  There is a separate helper function for each type of HTTP request.

- [conn$get() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-get) - to make a GET request
- [conn$post() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-post) - make a POST request
- [conn$put() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-put) - make a PUT request

### Request Parameters

Each of the request functions (`get`, `post`, `put`) can take the following parameters:

- `call` - The BrAPI endpoint to make the request to
- `query` - (optional) A named list of query parameters
- `body` - (optional) A named list or vector of body parameters (this will be automatically converted to JSON)
- `page` - the index of the page of results to return
  - When `page="all"`, all of the available pages will be fetched sequentially and the response properties of all of the individual pages along with the combined data from all of the pages will be returned
- `pageSize` - the maximum size of the page of results to return

### Response Format

The return value for each of the request functions (`get`, `post`, `put`) will return a named list containing the properties of the Response.

For a singe-page request:

- `response` - the `httr` response object
- `status` - the parsed HTTP status
- `content` - the full content of the body of the response
- `metadata` - the metadata object from the body of the reponse, if returned
- `data` - the data object from the body of the response, if returned

For a multi-page request (when `page="all"`):

- `response` - a list of the `httr` response object by page
- `status` - a list of the parsed HTTP status by page
- `content` - a list of the full content of the body of the response by page
- `metadata` - a list of the metadata object from the body of the response by page, if returned
- `data` - a list of the data object from the body of the response by page, if returned
- `combined_data` - a combined vector of the data from all of the pages, if returned

## Examples

```R
# GET Request
> wheat <- getBrAPIConnection("T3/Wheat")
> resp <- wheat$get("/studies", query=list(programName="Cornell University"))

# POST Request
> sandbox <- BrAPIConnection$new("wheat-sandbox.triticeaetoolbox.org")
> d1 <- list(observationUnitDbId="ou1", observationVariableDbId="ov1", value=50)
> d2 <- list(observationUnitDbId="ou2", observationVariableDbId="ov1", value=40)
> data <- list(d1, d2)
> resp <- sandbox$post("/token", query=list(username="testing", password="testing123"))
> resp <- sandbox$post("/observations", body=data, token=resp$content$access_token)

# PUT Request
> sandbox <- BrAPIConnection$new("wheat-sandbox.triticeaetoolbox.org")
> d1 <- list(observationDbId = "ob1", observationUnitDbId="ou1", observationVariableDbId="ov1", value=60)
> d2 <- list(observationDbId = "ob2", observationUnitDbId="ou2", observationVariableDbId="ov1", value=70)
> data <- list(d1, d2)
> resp <- sandbox$post("/token", query=list(username="testing", password="testing123"))
> resp <- sandbox$put("/observations", body=data, token=resp$content$access_token)
```