#' Create BrAPI Connection
#'
#' Create a BrAPI connection to the specified host
#'
#' @param host The BrAPI server hostname
#' @param protocol (optional) the HTTP protocol (either 'http' or 'https') (DEFAULT: https)
#' @param path (optional) the base path to the BrAPI endpoints (without the version) (DEFAULT: /brapi/)
#' @param version (optional) the BrAPI version to use (DEFAULT: v2)
#' @param is_breedbase (optional) set to TRUE if the connection is to a breedbase instance (DEFAULT: FALSE)
#'
#' @examples
#' wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase=TRUE)
#' oatv1 <- createBrAPIConnection("oat.triticeaetoolbox.org", version="v1", is_breedbase=TRUE)
#'
#' @return BrAPIConnection
#'
#' @export
createBrAPIConnection <- function(
  host = NULL,
  protocol = "https",
  path = "/brapi/",
  version = "v2",
  is_breedbase = FALSE
) {

  # Check for required host
  if ( is.null(host) ) {
    stop("Cannot create Connection: host is required")
  }

  # Create Connection with specified properties
  connection <- BrAPIConnection$new(host = host, protocol = protocol, path = path, version = version, is_breedbase = is_breedbase)

  # Return the Connection
  return(connection)

}



#' Get Known BrAPI Connection
#'
#' Get the connection details for a known BrAPI server
#'
#' @param name The name of the known BrAPI server
#'
#' @examples
#' wheat <- getBrAPIConnection("T3/Wheat")
#' cassava <- getBrAPIConnection("Cassavabase")
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



#' Get all Known BrAPI Connections
#'
#' Return a list of all known BrAPI Connections
#'
#' @examples
#' connections <- getBrAPIConnections()
#'
#' @return list(BrAPIConnection) 
#'
#' @export
#' @include known_connections.R
getBrAPIConnections <- function() {
  return(KNOWN_BRAPI_CONNECTIONS)
}



#' List Known BrAPI Connections
#'
#' List the known BrAPI connections that can be used in `getBrAPIConnection(name)`.
#' 
#' @examples
#' listBrAPIConnections()
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

