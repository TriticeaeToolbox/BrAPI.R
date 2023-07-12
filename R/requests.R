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
        page = ifelse("page" %in% names(query), query$page, page)
        pageSize = ifelse("pageSize" %in% names(query), query$pageSize, pageSize)
        query$page = ifelse(page == "all", 0, page)
        query$pageSize = pageSize
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
    content = content(resp)
    warn_for_status(resp)

    # Get Pagination Info
    currentPage = "?"
    totalPages = "?"
    if ( "metadata" %in% names(content)&& "pagination" %in% names(content$metadata) ) {
        currentPage = content$metadata$pagination$currentPage
        totalPages = content$metadata$pagination$totalPages
    }

    # Print Response Info
    cat(
        sprintf("Response [%s]", resp$url),
        sprintf("  %s", http_status(resp)$message),
        sprintf("  Content Type: %s", http_type(resp)),
        sprintf("  Pagination: page %s of %s [pageSize = %s]", currentPage, totalPages, pageSize),
        sep = "\n"
    )
    
    # Check for error message in the metadata
    if ( "metadata" %in% names(content) && "status" %in% names(content$metadata) ) {
        for ( status in content$metadata$status ) {
            if ( status$messageType == "ERROR" ) {
                warning(status$message)
            }
        }
    }


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
        statuses[["page0"]] = http_status(resp)
        contents[["page0"]] = content
        metadata[["page0"]] = content$metadata
        data[["page0"]] = content$result$data
        combined_data = content$result$data

        # Make a new request for each page
        for ( nextPage in c(1:(totalPages-1)) ) {
            query$page = nextPage
            nextPageResp = BrAPIRequest(
                conn=conn,
                method=method,
                call=call,
                query=query,
                body=body,
                page=nextPage,
                pageSize=pageSize,
                token=token
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

    else {

        return(list(
            response = resp,
            status = http_status(resp),
            content = content,
            metadata = content$metadata,
            data = content$result$data
        ))

    }

}