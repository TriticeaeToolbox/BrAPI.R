library(R6)

#' BrAPI Connection Class
#'
#' An R6 Class representing a connection to a BrAPI server.
#'
#' This Class provides all of the information needed for connecting to a BrAPI server.
#' The host field is required.  For all other fields, the default value will be used if one is not provided.
#' Add the `is_breedbase=TRUE` argument to enable breedbase-specific functions.
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
#' wheat <- BrAPIConnection$new("wheat.triticeaetoolbox.org", is_breedbase=TRUE)
#' wheatv1 <- BrAPIConnection$new("wheat.triticeaetoolbox.org", version="v1")
#' 
#' # Using the createBrAPIConnection function
#' barley <- createBrAPIConnection("barley.triticeaetoolbox.org")
#' barleyv1 <- createBrAPIConnection("barley.triticeaetoolbox.org", version="v1")
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

    #' @field is_breedbase A flag to indicate this BrAPI connection is to a breedbase instance.  This 
    #' adds additional support for breedbase-specific functionality. (Default: `FALSE`)
    is_breedbase = "boolean",

    #' @description Create a new `BrAPIConnection` object
    #' 
    #' @param host (required) The hostname of the BrAPI server
    #' @param protocol (optional) The HTTP protocol - either 'http' or 'https'
    #' @param path (optional) The base path of the BrAPI endpoints
    #' @param version (optional) The BrAPI version
    #' @param is_breedbase (optional) set to TRUE if the connection is to a breedbase instance
    #' 
    #' @return `BrAPIConnection` object
    initialize = function(host, protocol='https', path='/brapi/', version='v2', is_breedbase = FALSE) {
      self$host <- host
      self$protocol <- protocol
      self$path <- path
      self$version <- version
      self$is_breedbase <- is_breedbase
    },

    #' @description Make a GET request
    #' @param call The BrAPI endpoint to request
    #' @param query (optional) A named list of query parameters
    #' @param page (optional) The index of the page of results (use 'all' to get all pages) (Default: 0)
    #' @param pageSize (optional) The max size of the result pages (Default: 10)
    #' @param token (optional) An Authorization token to add to the request
    #' @param verbose (optional) Set to true to include additional output to the console about the Response
    #' @param ... (optional) Additional arguments passed to `httr`
    #' @return A named list of Response properties
    #' @examples
    #' # Making a GET request
    #' resp <- wheat$get("/germplasm", pageSize=100)
    #' resp <- wheat$get("/studies", pageSize=1000, page="all")
    #' resp <- wheat$get("/studies", query=list(programName="Cornell University"), pageSize=1000)
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
    #' @param verbose (optional) Set to true to include additional output to the console about the Response
    #' @param ... (optional) Additional arguments passed to `httr`
    #' @return A named list of Response properties
    #' @examples
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
    #' @param verbose (optional) Set to true to include additional output to the console about the Response
    #' @param ... (optional) Additional arguments passed to `httr`
    #' @return A named list of Response properties
    put = function(call, ...) {
      BrAPIRequest("PUT", private$url(), call, ...)
    },

    #' @description Make a Breedbase Search Wizard request
    #'
    #' @param data_type The data type to return after filtering
    #' @param filters A list of the filters (up to 3) to apply to the search.  The key should be the 
    #' name of the data type and the value should be a vector of database ids or names of the items 
    #' to include in the filter.
    #' 
    #' It is better to use IDs if you have them - when you use names, the function will make additional 
    #' queries to lookup the IDs for the names you provide.
    #'
    #' Supported data types include: accessions, organisms, breeding_programs, genotyping_protocols, genotyping_projects, locations, plants, plots, tissue_sample, seedlots, trait_components, traits, trials, trial_designs, trial_types, years
    #' @param verbose Set to TRUE to include logging information
    #' 
    #' @return A response with the matching data.
    #' The $content key contains the raw breedbase response.
    #' The $data key contains parsed data: a list parsed into `ids`, `names` and `map` (a named list of item names -> ids)
    #'
    #' @examples
    #' wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase = TRUE)
    #'
    #' # find matching trials, filtered by two breeding programs (identified by ids) and one year
    #' trials <- wheat$wizard("trials", list(breeding_programs = c(327,367), years = c(2023)))
    #'
    #' # find matching accessions, filtered by field trials (identified by name)
    #' accessions <- wheat$wizard("accessions", list(trials = c("CornellMaster_2024_Helfer", "CornellMaster_2025_McGowan")))
    #'
    #' # find genotyping protocols that have data for the above set of accessions
    #' geno_protocols <- wheat$wizard("genotyping_protocols", list(accessions = accessions$data$ids))
    wizard = function(data_type, filters = list(), verbose = FALSE) {
      private$check_if_breedbase()
      BreedbaseRequest(private$base(), "wizard", data_type, filters, verbose)
    },


    #' @description Download a Breedbase VCF File
    #'
    #' NOTE: Depending on the number of markers and accessions, this download may take a 
    #' very long time to complete.  You may want to use the conn$vcf_archived() function 
    #' to download a static archived VCF file of a genotyping project, if one is available.
    #'
    #' @param output The path to the output VCF file
    #' @param genotyping_protocol_id The Database ID of the genotyping protocol to download
    #' @param accessions (optional) A list of Accession Database IDs to use as a filter for the VCF data
    #' @param verbose Set to TRUE to include logging information
    #'
    #' @return Status information about the request.  If successful, the genotype data will 
    #' be downloaded to the VCF file specified by the output argument.
    #'
    #' @examples
    #' \dontrun{
    #' wheat <- getBrAPIConnection("T3/WheatCAP")
    #' wheat$vcf("~/Desktop/my_data.vcf", genotyping_protocol_id = 249)
    #' wheat$vcf("~/Desktop/my_data.vcf", genotyping_protocol_id = 249, accessions = c(228677, 1666408))
    #' }
    vcf = function(output, genotyping_protocol_id, accessions = NULL, verbose = FALSE) {
      private$check_if_breedbase()
      BreedbaseRequest(private$base(), "vcf", output, genotyping_protocol_id, accessions, verbose)
    },

    #' @description Download an Archived Breedbase VCF File
    #'
    #' This function will list all of the available archived VCF files available for the specified protocol 
    #' and/or project.  You can select one to download and save to the provided output file.
    #'
    #' The archived files are saved at the project-level.  So, if you specify a protocol, you'll get a list
    #' of all of the available files for each project in that protocol.  If you're performing analysis at 
    #' the protocol-level, you'll need to manually merge the VCF files from each project in that protocol.
    #'
    #' @param output The path to the output VCF file
    #' @param genotyping_protocol_id The Database ID of the genotyping protocol
    #' @param genotyping_project_id The Database ID of the genotyping project
    #' @param verbose Set to TRUE to include logging information
    #'
    #' @return Status information about the request. If the download of an available archived VCF file is
    #' successful, the genotype data will be downloaded to the VCF file specified by the output argument.
    #'
    #' @examples
    #' \dontrun{
    #' wheat <- getBrAPIConnection("T3/WheatCAP")
    #' wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_protocol_id=233)
    #' wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_project_id=10371)
    #' }
    vcf_archived = function(output, genotyping_protocol_id = NULL, genotyping_project_id = NULL, verbose = FALSE) {
      private$check_if_breedbase()
      BreedbaseRequest(private$base(), "vcf_archived", output, genotyping_protocol_id, genotyping_project_id, verbose)
    }

  ),

  private = list(

    # Generate the base URL of the connection
    # Returns a String in the format `$protocol://$host`
    base = function() {
      protocol <- self$protocol
      host <- self$host

      protocol <- sub(":?/+$", "", protocol)
      host <- sub("^https?://", "", host)

      return(paste(protocol, host, sep='://'))
    },
    
    # Generate the full URL to the BrAPI endpoints
    # Returns a String in the format `$base/$path/$version/`
    url = function() {
      base <- private$base()
      path <- self$path
      version <- self$version
      
      path <- sub("^/+", "", path)
      path <- sub("/+$", "", path)
      path <- sub("//+", "/", path)
      
      return(paste(base, path, version, sep='/'))
    },

    # Check if this connection has opted-in to breedbase-specific functions
    check_if_breedbase = function() {
      if ( !self$is_breedbase ) {
        stop("Breedbase-specific functions are not enabled for this connection.  Set the connection parameter `is_breedbase` to TRUE to enable this function.")
      }
    }

  )
)
