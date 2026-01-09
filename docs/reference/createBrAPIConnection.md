# Create BrAPI Connection

Create a BrAPI connection to the specified host

## Usage

``` r
createBrAPIConnection(
  host = NULL,
  protocol = "https",
  path = "/brapi/",
  version = "v2",
  is_breedbase = FALSE
)
```

## Arguments

- host:

  The BrAPI server hostname

- protocol:

  (optional) the HTTP protocol (either 'http' or 'https') (DEFAULT:
  https)

- path:

  (optional) the base path to the BrAPI endpoints (without the version)
  (DEFAULT: /brapi/)

- version:

  (optional) the BrAPI version to use (DEFAULT: v2)

- is_breedbase:

  (optional) set to TRUE if the connection is to a breedbase instance
  (DEFAULT: FALSE)

## Value

BrAPIConnection

## Examples

``` r
wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase=TRUE)
oatv1 <- createBrAPIConnection("oat.triticeaetoolbox.org", version="v1", is_breedbase=TRUE)
```
