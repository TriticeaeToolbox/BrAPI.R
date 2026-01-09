# Get Known BrAPI Connection

Get the connection details for a known BrAPI server

## Usage

``` r
getBrAPIConnection(name = NULL)
```

## Arguments

- name:

  The name of the known BrAPI server

## Value

BrAPIConnection

## Examples

``` r
wheat <- getBrAPIConnection("T3/Wheat")
cassava <- getBrAPIConnection("Cassavabase")
```
