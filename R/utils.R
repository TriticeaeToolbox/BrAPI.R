#' Create BrAPI Connection (with database URL)
#'
#' Create a BrAPI connection to the specified host / URL of the database.  This can 
#' be used to create a BrAPI connection to any BrAPI-compliant database.
#'
#' @param host The BrAPI server hostname
#' @param protocol (optional) the HTTP protocol (either 'http' or 'https') (DEFAULT: https)
#' @param path (optional) the base path to the BrAPI endpoints (without the version) (DEFAULT: /brapi/)
#' @param version (optional) the BrAPI version to use (DEFAULT: v2)
#' @param params (optional) additional query params (added as a named list) that are added to each request (DEFAULT: none)
#' @param is_breedbase (optional) set to TRUE if the connection is to a breedbase instance (DEFAULT: FALSE)
#'
#' @examples
#' wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase=TRUE)
#' oatv1 <- createBrAPIConnection("oat.triticeaetoolbox.org", version="v1", is_breedbase=TRUE)
#' grin <- createBrAPIConnection("npgsweb.ars-grin.gov", path="/gringlobal/brapi/", params=list(commoncropname = "WHEAT"))
#'
#' @return BrAPIConnection
#'
#' @export
createBrAPIConnection <- function(
  host = NULL,
  protocol = "https",
  path = "/brapi/",
  version = "v2",
  params = list(),
  is_breedbase = FALSE
) {

  # Check for required host
  if ( is.null(host) ) {
    stop("Cannot create Connection: host is required")
  }

  # Create Connection with specified properties
  connection <- BrAPIConnection$new(host = host, protocol = protocol, path = path, version = version, params = params, is_breedbase = is_breedbase)

  # Return the Connection
  return(connection)

}



#' Get Known BrAPI Connection (by database name)
#'
#' Get a BrAPI Connection for a pre-defined database by name.  Use the
#' `listBrAPIConnections()` function to get a list of all pre-defined 
#' databases.  This function will return the connection, with all of 
#' its properties set, for the named database.
#'
#' @param name The name of the known BrAPI server
#'
#' @examples
#' wheat <- getBrAPIConnection("T3/Wheat")
#' cassava <- getBrAPIConnection("Cassavabase")
#' grin <- getBrAPIConnection("USDA-GRIN Wheat")
#'
#' @return BrAPIConnection
#'
#' @export
#' @include known_connections.R
getBrAPIConnection <- function(name=NULL) {
  if ( !is.null(name) && name %in% names(KNOWN_BRAPI_CONNECTIONS) ) {
    return(KNOWN_BRAPI_CONNECTIONS[[name]])
  }
  listBrAPIConnections()
  if ( is.null(name) ) {
    stop("The name of a known connection is required")
  }
  else {
    stop(sprintf("No known connection with the name %s", name))
  }
}


#' List Known BrAPI Connections
#'
#' List the known BrAPI connections that can be used in `getBrAPIConnection(name)`.
#' 
#' @examples
#' listBrAPIConnections()
#' #Known BrAPI Connections:
#' #  T3/Wheat = wheat.triticeaetoolbox.org [v2]
#' #  T3/Wheat Sandbox = wheat-sandbox.triticeaetoolbox.org [v2]
#' #  T3/WheatCAP = wheatcap.triticeaetoolbox.org [v2]
#' #  T3/Oat = oat.triticeaetoolbox.org [v2]
#' #  T3/Oat Sandbox = oat-sandbox.triticeaetoolbox.org [v2]
#' #  T3/Barley = barley.triticeaetoolbox.org [v2]
#' #  T3/Barley Sandbox = barley-sandbox.triticeaetoolbox.org [v2]
#' #  Cassavabase = cassavabase.org [v2]
#' #  USDA-GRIN Wheat = npgsweb.ars-grin.gov [v2]
#' #  USDA-GRIN Oat = npgsweb.ars-grin.gov [v2]
#' #  USDA-GRIN Barley = npgsweb.ars-grin.gov [v2]
#'
#' @export
#' @include known_connections.R
listBrAPIConnections <- function() {
  cat("Known BrAPI Connections:\n")
  for ( name in names(KNOWN_BRAPI_CONNECTIONS) ) {
    conn <- KNOWN_BRAPI_CONNECTIONS[[name]]
    cat(sprintf("  %s = %s [%s]\n", name, conn$host, conn$version))
  }
}

