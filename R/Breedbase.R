library(httr)


# 
# Supported data types for the Search Wizard
#
SUPPORTED_DATA_TYPES = c("accessions", "organisms", "breeding_programs", "genotyping_protocols", "genotyping_projects", "locations", "plants", "plots", "tissue_sample", "seedlots", "trait_components", "traits", "trials", "trial_designs", "trial_types", "years")

#
# Handle each specific Breedbase Request in its individual function
# Return an error if the request is not supported
#
BreedbaseRequest <- function(base, request, ...) {
  if ( request == "wizard" ) {
    return(BreedbaseRequestWizard(base, ...))
  }
  else {
    stop("Unsupported breedbase request name")
  }
}


#
# Request Search Wizard Data
# 
# The data_type (type of data to return as matches) is required and must be a supported data type
# 
# The filters is a list of data types and items to filter the search by.  The name of the list item
# key is a supported data type name and the list item value is a vector of item DB ids.  The order of 
# the list items is how they would be applied in the columns of the search wizard.
#
# The function will return a list of matching data.  The ids key is a vector of all unique db ids of the 
# matching items.  The names key is a vector of all unique database names of the matching items.  The data
# key is a list with the item name as the key and the item db id as the value.
#
BreedbaseRequestWizard <- function(base, data_type, filters = list(), verbose = FALSE) {

  # Check data type names
  for ( dt in c(data_type, names(filters)) ) {
    if ( ! dt %in% SUPPORTED_DATA_TYPES ) {
      print("Supported Data Types:")
      print(SUPPORTED_DATA_TYPES)
      stop(paste0("The data type '", dt, "' is not supported"))
    }
  }

  # Check length of filters
  if ( length(filters) > 3 ) {
    stop("A maximum of 3 filters is allowed")
  }

  # Build Body of HTTP Requst
  parsed_filters = list()
  body = list()
  if ( length(filters) > 0 ) {

    # Check and parse each of the filters (name = data type, value = item values)
    for ( i in c(1:length(filters)) ) {
      dt = names(filters)[[i]]
      values = filters[[i]]
      parsed_values = c()
      lookup_values = c()

      # Check each of the filter values...
      for ( v in values ) {

        # ...if it's not numeric, we'll need to lookup the id by name
        if ( suppressWarnings(is.na(as.numeric(v))) ) {
          lookup_values = c(lookup_values, v)
        }

        # ... if it is numeric, we can use it as is
        else {
          parsed_values = c(parsed_values, v)
        }

      }

      # If there are item values to lookup...
      if ( length(lookup_values) > 0 ) {

        # ... get all of the items of the filter's data type
        if ( verbose ) {
          cat(sprintf("... looking up %s by name ...\n", dt))
        }
        lookup_results = BreedbaseRequestWizard(base, dt, verbose = verbose)

        # ... and see if there is matching item by name
        # ... if there is a match, add its id to the parsed values list
        for ( lv in lookup_values ) {
          lvid = lookup_results$data$map[[lv]]
          if ( !is.null(lvid) ) {
            parsed_values = c(parsed_values, lvid)
          }
          else {
            warning(sprintf("There is no matching item of type %s with the name %s", dt, lv))
          }
        }

      }

      # Add the parsed values to the parsed filters
      parsed_filters[[dt]] = parsed_values
    }

    # Convert the filters into the breedbase-specific HTTP request body
    for ( i in c(1:length(names(parsed_filters))) ) {
      dt = names(parsed_filters)[[i]]
      if ( !is.null(dt) ) {
        body = append(body, list("categories[]" = dt))
        for ( v in parsed_filters[[i]] ) {
          d = list()
          d[[paste0("data[", i-1, "][]")]] = v
          body = append(body, d)
        }
      }
    }

  }
  body = append(body, list("categories[]" = data_type))

  # Make the HTTP request
  resp = httr::POST(paste(base, "ajax", "breeder", "search", sep="/"), body = body, encode = "multipart")
  content = httr::content(resp)
  httr::warn_for_status(resp)

  # Print Response Info
  if ( verbose ) {
    cat(
      sprintf("Response [POST] <%s>", resp$url),
      sprintf("  %s", httr::http_status(resp)$message),
      sprintf("  Content Type: %s", httr::http_type(resp)),
      sep = "\n"
    )
  }

  # Process the data into ids, names, and a map of names -> ids
  data = list(
    ids = c(),
    names = c(),
    map = list()
  )
  if ( "list" %in% names(content) ) {
    for ( item in content$list ) {
      id = item[[1]]
      name = item[[2]]
      data$ids = c(data$ids, id)
      data$names = c(data$names, name)
      data$map[[name]] = id
    }
  }

  if ( verbose ) {
    cat(
      sprintf("  Requested Data Type: %s", data_type),
      sprintf("  Matches Found: %i", length(data$ids)),
      sep = "\n"
    )
  }

  return(list(
    response = resp,
    status = httr::http_status(resp),
    content = content,
    data = data
  ))
}