library(R6)

#' BrAPI Connection Class
#'
#' An R6 Class representing a connection to a BrAPI server.
#'
#' This Class provides all of the information needed for connecting to a BrAPI server.
#' The host field is required.  For all other fields, the default value will be used if one is not provided.
#' 
#' This Class also provides helper functions for making requests to the BrAPI server.  Use `conn$get()` to make 
#' a GET request, `conn$post()` to make a POST request, and `conn$put()` to make a PUT request.
#' 
#' The return value of a request function contains a named list with the properties of the Response(s).
#' 
#' For a singe-page request:
#'  - `response` = the `httr` response object
#'  - `status` = the parsed HTTP status
#'  - `content` = the full content of the body of the response
#'  - `metadata` = the metadata object from the body of the reponse, if returned
#'  - `data` = the data object from the body of the response, if returned
#' 
#' For a multi-page request (when `page="all"`):
#'  - `response` = a list of the `httr` response object by page
#'  - `status` = a list of the parsed HTTP status by page
#'  - `content` = a list of the full content of the body of the response by page
#'  - `metadata` = a list of the metadata object from the body of the response by page, if returned
#'  - `data` = a list of the data object from the body of the response by page, if returned
#'  - `combined_data` = a combined vector of the data from all of the pages, if returned
#' 
#' @examples 
#' # Directly Creating a new BrAPIConnection Object
#' wheat <- BrAPIConnection$new("wheat.triticeaetoolbox.org")
#' wheatv1 <- BrAPIConnection$new("wheat.triticeaetoolbox.org", version="v1")
#' 
#' # Using the createBrAPIConnection function
#' barley <- createBrAPIConnection("barley.triticeaetoolbox.org")
#' barleyv1 <- createBrAPIConnection("barley.triticeaetoolbox.org", version="v1")
#' 
#' # Making a GET request
#' resp <- wheat$get("/germplasm", pageSize=100)
#' resp <- wheat$get("/studies", pageSize=1000, page="all")
#' resp <- wheat$get("/studies", query=list(programName="Cornell University"), pageSize=1000)
#' 
#' # Make a POST request
#'\dontrun{
#' sandbox <- BrAPIConnection$new("wheat-sandbox.triticeaetoolbox.org")
#' d1 <- list(observationUnitDbId="ou1", observationVariableDbId="ov1", value=50)
#' d2 <- list(observationUnitDbId="ou2", observationVariableDbId="ov1", value=40)
#' data <- list(d1, d2)
#' resp <- sandbox$post("/token", query=list(username="testing", password="testing123"))
#' resp <- sandbox$post("/observations", body=data, token=resp$content$access_token)
#'}
#'
#' @name BrAPIConnection
#'
#' @export
BrAPIConnection <- R6::R6Class("BrAPIConnection",
  public = list(

    #' @field protocol The HTTP protocol - either 'http' or 'https' (Default: `https`)
    protocol = "character",

    #' @field host The hostname of the BrAPI server
    host = "character",

    #' @field path The base bath of the BrAPI endpoints (not including the version) (Default: `/brapi/`)
    path = "character",

    #' @field version The BrAPI version (such as 'v1' or 'v2') (Default: `v2`)
    version = "character",

    #' @description Create a new `BrAPIConnection` object
    #' 
    #' @param host (required) The hostname of the BrAPI server
    #' @param protocol (optional) The HTTP protocol - either 'http' or 'https'
    #' @param path (optional) The base path of the BrAPI endpoints
    #' @param version (optional) The BrAPI version
    #' 
    #' @return `BrAPIConnection` object
    initialize = function(host, protocol='https', path='/brapi/', version='v2') {
      self$host <- host
      self$protocol <- protocol
      self$path <- path
      self$version <- version
    },

    #' @description Make a GET request
    #' @param call The BrAPI endpoint to request
    #' @param query (optional) A named list of query parameters
    #' @param page (optional) The index of the page of results (use 'all' to get all pages) (Default: 0)
    #' @param pageSize (optional) The max size of the result pages (Default: 10)
    #' @param token (optional) An Authorization token to add to the request
    #' @param ... (optional) Additional arguments passed to `httr`
    #' @return A named list of Response properties
    get = function(call, ...) {
      BrAPIRequest("GET", private$url(), call, ...)
    },

    #' @description Make a POST request
    #' @param call The BrAPI endpoint to request
    #' @param query (optional) A named list of query parameters
    #' @param body (optional) A named list or vector of the request body (will be converted to JSON)
    #' @param page (optional) The index of the page of results (use 'all' to get all pages) (Default: 0)
    #' @param pageSize (optional) The max size of the result pages (Default: 10)
    #' @param token (optional) An Authorization token to add to the request
    #' @param ... (optional) Additional arguments passed to `httr`
    #' @return A named list of Response properties
    post = function(call, ...) {
      BrAPIRequest("POST", private$url(), call, ...)
    },

    #' @description Make a PUT request
    #' @param call The BrAPI endpoint to request
        #' @param query (optional) A named list of query parameters
    #' @param body (optional) A named list or vector of the request body (will be converted to JSON)
    #' @param page (optional) The index of the page of results (use 'all' to get all pages) (Default: 0)
    #' @param pageSize (optional) The max size of the result pages (Default: 10)
    #' @param token (optional) An Authorization token to add to the request
    #' @param ... (optional) Additional arguments passed to `httr`
    #' @return A named list of Response properties
    put = function(call, ...) {
      BrAPIRequest("PUT", private$url(), call, ...)
    }

  ),

  private = list(
    
    # Generate the full URL to the BrAPI endpoints
    # Returns a String in the format `$protocol://$host/$path/$version/`
    url = function() {
      protocol <- self$protocol
      host <- self$host
      path <- self$path
      version <- self$version
      
      protocol <- sub(":?/+$", "", protocol)
      host <- sub("^https?://", "", host)
      path <- sub("^/+", "", path)
      path <- sub("/+$", "", path)
      path <- sub("//+", "/", path)
      
      return(paste0(protocol, '://', host, '/', path, '/', version))
    }

  )
)
