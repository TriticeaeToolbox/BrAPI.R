library(httr)

# BrAPI Request
# 
# Make a BrAPI request using the provided method, base URL, and BrAPI call.
#
# In most cases, you won't call this function directly.  Instead you'll use the helper functions
# provided by the BrAPIConnection object.  For example:
# wheat <- getBrAPIConnection("T3/Wheat")
# resp <- wheat$get("/germplasm", pageSize=500)
# resp <- wheat$post("/observations", body=data)
# 
# @param method The HTTP Method to use
# @param base The base URL of the BrAPI endpoints
# @param call The BrAPI endpoint to request
# @param query A named list of query parameters
# @param body A named list or vector of a POST request's body
# @param page The page of results to return (Default: 0). When set to 'all', returns all pages
# @param pageSize The size of a page of results to return (Default: 10)
# @param token An Authorization Token to be added as an Authorization Header
# @param verbose When set to true, print some response metadata to the console
# 
# @return A named list containing the Response properties
BrAPIRequest <- function(method, base, call, ..., query=list(), body=list(), page=0, pageSize=10, token=NULL, verbose=FALSE) {

  # Check for required arguments
  if ( !hasArg(method) ) stop("The HTTP method is required!")
  if ( !hasArg(base) ) stop("The BrAPI base url is required!")
  if ( !hasArg(call) ) stop("The BrAPI call is required!")

  # Build the full URL
  call = sub("^/+", "", call)
  url = paste(base, call, sep="/")

  # Add page parameters to the query list, for GET requests
  if ( method == "GET" ) {
    page = ifelse("page" %in% names(query), query$page, page)
    pageSize = ifelse("pageSize" %in% names(query), query$pageSize, pageSize)
    query$page = ifelse(page == "all", 0, page)
    query$pageSize = pageSize
  }

  # Add token as Authorization header, if provided
  config = list()
  if ( !is.null(token) ) {
    config = httr::add_headers(Authorization = paste("Bearer", token, sep=" "))
  }

  # Make the Request
  resp = httr::VERB(
    method, url, config,
    query = query,
    body = body,
    encode = "json",
    ...
  )
  content = httr::content(resp)
  httr::warn_for_status(resp)

  # Get Pagination Info
  currentPage = "?"
  totalPages = "?"
  if ( "metadata" %in% names(content)&& "pagination" %in% names(content$metadata) ) {
    currentPage = content$metadata$pagination$currentPage
    totalPages = content$metadata$pagination$totalPages
  }

  # Print Response Info
  if ( verbose ) {
    cat(
      sprintf("Response [%s] <%s>", method, resp$url),
      sprintf("  %s", httr::http_status(resp)$message),
      sprintf("  Content Type: %s", httr::http_type(resp)),
      sprintf("  Pagination: page %s of %s [pageSize = %s]", currentPage, totalPages, pageSize),
      sep = "\n"
    )
  }

  # Check for error message in the metadata
  if ( "metadata" %in% names(content) && "status" %in% names(content$metadata) ) {
    for ( status in content$metadata$status ) {
      if ( status$messageType == "ERROR" ) {
        warning(status$message)
      }
    }
  }

  # ALL PAGES REQUESTED
  # Return vectors of response data, an item for each page requested
  if ( page == "all" ) {

    # Vectors to hold data
    responses = list()
    statuses = list()
    contents = list()
    metadata = list()
    data = list()
    combined_data = c()

    # Add data from first page
    responses[["page0"]] = resp
    statuses[["page0"]] = httr::http_status(resp)
    contents[["page0"]] = content
    metadata[["page0"]] = content$metadata
    data[["page0"]] = content$result$data
    combined_data = content$result$data

    # Make a new request for each page
    for ( nextPage in c(1:(totalPages-1)) ) {
      query$page = nextPage
      nextPageResp = BrAPIRequest(
        method=method,
        base=base,
        call=call,
        query=query,
        body=body,
        page=nextPage,
        pageSize=pageSize,
        token=token,
        ...
      )
      key = paste0("page", nextPage)
      responses[[key]] = nextPageResp$response
      statuses[[key]] = nextPageResp$status
      contents[[key]] = nextPageResp$content
      metadata[[key]] = nextPageResp$content$metadata
      data[[key]] = nextPageResp$content$result$data
      combined_data = c(combined_data, nextPageResp$content$result$data)
    }

    return(list(
      response = responses,
      status = statuses,
      content = contents,
      metadata = metadata,
      data = data,
      combined_data = combined_data
    ))

  }

  # SINGLE PAGE REQUESTED
  # Return all of the Response properties
  else {

    return(list(
      response = resp,
      status = httr::http_status(resp),
      content = content,
      metadata = content$metadata,
      data = content$result$data
    ))

  }

}
