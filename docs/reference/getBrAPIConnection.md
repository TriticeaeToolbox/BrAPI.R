# Get Known BrAPI Connection (by database name)

Get a BrAPI Connection for a pre-defined database by name. Use the
[`listBrAPIConnections()`](https://triticeaetoolbox.github.io/BrAPI.R/reference/listBrAPIConnections.md)
function to get a list of all pre-defined databases. This function will
return the connection, with all of its properties set, for the named
database.

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
grin <- getBrAPIConnection("USDA-GRIN Wheat")
```
