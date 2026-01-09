# BrAPI Request

Make a BrAPI request using the provided BrAPIConnection and method to
the specified BrAPI call. The BrAPIConnection provides the BrAPI server
details (such as the hostname and path), the method specifies the HTTP
method (GET, POST, etc) and the call specifies the specific BrAPI
endpoint to request.

## Usage

``` r
BrAPIRequest(
  method,
  base,
  call,
  ...,
  query = list(),
  body = list(),
  page = 0,
  pageSize = 10,
  token = NULL
)
```

## Arguments

- method:

  The HTTP Method to use

- base:

  The base URL of the BrAPI endpoints

- call:

  The BrAPI endpoint to request

- query:

  A named list of query parameters

- body:

  A named list or vector of a POST request's body

- page:

  The page of results to return (Default: 0). When set to 'all',

- pageSize:

  The size of a page of results to return (Default: 10)

- token:

  An Authorization Token to be added as an Authorization Header

## Value

A named list containing the Response properties

## Details

In most cases, you won't call this function directly. Instead you'll use
the helper functions provided by the BrAPIConnection object. For
example: wheat \<- getBrAPIConnection("T3/Wheat") resp \<-
wheat\$get("/germplasm", pageSize=500) resp \<-
wheat\$post("/observations", body=data)
