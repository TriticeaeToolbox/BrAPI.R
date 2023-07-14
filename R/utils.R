#' Create BrAPI Connection
#'
#' Create a BrAPI connection to the specified host
#'
#' @param host The BrAPI server hostname
#' @param protocol (optional) the HTTP protocol (either 'http' or 'https') (DEFAULT: https)
#' @param path (optional) the base path to the BrAPI endpoints (without the version) (DEFAULT: /brapi/)
#' @param version (optional) the BrAPI version to use (DEFAULT: v2)
#'
#' @examples
#' wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org")
#' oatv1 <- createBrAPIConnection("oat.triticeaetoolbox.org", version="v1")
#'
#' @return BrAPIConnection
#'
#' @export
createBrAPIConnection <- function(
  host = NULL,
  protocol = NULL,
  path = NULL,
  version = NULL
) {

  # Check for required host
  if ( is.null(host) ) {
    stop("Cannot create Connection: host is required")
  }

  # Set default parameters
  if ( is.null(protocol) ) {
    protocol = "https"
  }
  if ( is.null(path) ) {
    path = "/brapi/"
  }
  if ( is.null(version) ) {
    version = "v2"
  }

  # Create Connection with specified properties
  connection <- BrAPIConnection$new(host = host, protocol = protocol, path = path, version = version)

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



#' List Known BrAPI Connections
#'
#' List the known BrAPI connections that can be used in `getBrAPIConnection(name)`.
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

