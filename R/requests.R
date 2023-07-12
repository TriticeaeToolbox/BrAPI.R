library(httr)

BrAPIRequest <- function(conn, method, call, ..., query=list(), body=list(), page=0, pageSize=10, token=NULL) {
	    
    # Check for required arguments
    if ( !hasArg(conn) ) stop("The BrAPI Connection is required!")
    if ( !hasArg(method) ) stop("The HTTP method is required!")
    if ( !hasArg(call) ) stop("The BrAPI call is required!")
    
    # Build the full URL
   	call = sub("^/+", "", call)
    url = paste(conn$url(), call, sep="/")
    
    # Add page parameters to the query list, for GET requests
    if ( method == "GET" ) {
      query$page = ifelse("page" %in% names(query), query$page, page)
      query$pageSize = ifelse("pageSize" %in% names(query), query$pageSize, pageSize)
    }
    
    # Add token as Authorization header, if provided
    config = list()
    if ( !is.null(token) ) {
      config = add_headers(Authorization = paste("Bearer", token, sep=" "))
    }
    
    # Make the Request
    resp = VERB(
      method, url, config,
      query = query,
      body = body,
      encode = "json"
    )
    
    # Print Response Info
    cat(
      sprintf("Response [%s]", resp$url),
      sprintf("  %s", http_status(resp)$message),
      sprintf("  Content Type: %s", http_type(resp)),
      sep = "\n"
    )
    warn_for_status(resp)
    content = content(resp)
    
    # Check for error message in the metadata
    if ( "metadata" %in% names(content) && "status" %in% names(content$metadata) ) {
      for ( status in content$metadata$status ) {
        if ( status$messageType == "ERROR" ) {
          warning(status$message)
        }
      }
    }
    
    # Parse the content
    return(list(
      response = resp,
      status = http_status(resp),
      content = content
    ))

}