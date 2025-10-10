library(httr)


# 
# Supported data types for the Search Wizard
#
SUPPORTED_DATA_TYPES = c("accessions", "organisms", "breeding_programs", "genotyping_protocols", "genotyping_projects", "locations", "plants", "plots", "tissue_sample", "seedlots", "trait_components", "traits", "trials", "trial_designs", "trial_types", "years")

#
# Handle each specific Breedbase Request in its individual function
# Return an error if the request is not supported
#
BreedbaseRequest <- function(conn, request, ...) {
  if ( request == "wizard" ) {
    return(BreedbaseRequestWizard(conn, ...))
  }
  if ( request == "vcf" ) {
    return(BreedbaseRequestVCF(conn, ...))
  }
  if ( request == "vcf_archived" ) {
    return(BreedbaseRequestArchivedVCF(conn, ...))
  }
  if ( request == "vcf_imputed" ) {
    return(BreedbaseRequestImputedVCF(conn, ...))
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
BreedbaseRequestWizard <- function(conn, data_type, filters = list(), verbose = FALSE) {

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
        lookup_results = BreedbaseRequestWizard(conn, dt, verbose = verbose)

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
  resp = httr::POST(paste(conn$base(), "ajax", "breeder", "search", sep="/"), body = body, encode = "multipart")
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


#
# Get Breedbase VCF File
#
# Download a VCF file of the requested data to a file on your local disk
#
# The output file and genotyping protocol ID must be specified.  If accessions are specified, the genotype
# data will be filtered to only include those accessions.
#
BreedbaseRequestVCF <- function(conn, output, genotyping_protocol_id, accessions = NULL, verbose = FALSE) {

  # Download entire genotyping protocol
  if ( is.null(accessions) ) {
    url = sprintf("%s/breeders/download_gbs_action/?protocol_id=%i&download_format=VCF&format=accession_ids", conn$base(), genotyping_protocol_id)
    resp = httr::GET(url, httr::write_disk(output, overwrite=TRUE), httr::timeout(3600))
    httr::warn_for_status(resp)
    if ( verbose ) {
      cat(
        sprintf("Response [GET] <%s>", resp$url),
        sprintf("  %s", httr::http_status(resp)$message),
        sprintf("  Protocol ID: %i", genotyping_protocol_id),
        sprintf("  Output File: %s", output),
        sep = "\n"
      )
    }
  }

  # Download subset of protocol with specific accessions
  else {
    url = sprintf("%s/breeders/download_gbs_action", conn$base())
    body = list(
      ids = gsub(" ", "", toString(accessions)),
      protocol_id = genotyping_protocol_id,
      format = "accession_ids",
      download_format = "VCF"
    )
    resp = httr::POST(url, body, httr::write_disk(output, overwrite=TRUE), httr::timeout(3600))
    httr::warn_for_status(resp)
    if ( verbose ) {
      cat(
        sprintf("Response [POST] <%s>", resp$url),
        sprintf("  %s", httr::http_status(resp)$message),
        sprintf("  Protocol ID: %i", genotyping_protocol_id),
        sprintf("  Accession IDs: %s", toString(accessions)),
        sprintf("  Output File: %s", output),
        sep = "\n"
      )
    }
  }

  return(list(
    response = resp,
    status = httr::http_status(resp),
    content = output,
    data = output
  ))
}

#
# Get Breedbase Archived VCF File
#
# Get the available archived VCF files based on the provided protocol and/or project
# Prompt the user to select a project
# Download the project's archived VCF file to the specified output
#
BreedbaseRequestArchivedVCF <- function(conn, output, genotyping_protocol_id = NULL, genotyping_project_id = NULL, verbose = FALSE) {

  # A protocol or a project is required
  if ( is.null(genotyping_protocol_id) && is.null(genotyping_project_id) ) {
    stop("A genotyping protocol and/or project is required")
  }

  # Get available archived files
  cat("Finding archived VCF files...\n")
  if ( verbose ) {
    if ( !is.null(genotyping_protocol_id) ) {
      cat(sprintf("  Genotyping Protocol: %i\n", genotyping_protocol_id))
    }
    if ( !is.null(genotyping_project_id) ) {
      cat(sprintf("  Genotyping Project: %i\n", genotyping_project_id))
    }
  }
  url = sprintf("%s/ajax/genotyping_project/has_archived_vcf", conn$base())
  resp = httr::GET(url, query=list(genotyping_protocol_id=genotyping_protocol_id, genotyping_project_id=genotyping_project_id))
  content = httr::content(resp)
  httr::warn_for_status(resp)

  # List available archived files
  cat("--> Select a file to download:\n")
  files=c()
  files_info=list()
  index=1
  for ( project in names(content) ) {
    for ( file in content[[project]] ) {
      cat(sprintf("[%i] %s (%s)\n", index, file$genotyping_project_name, file$genotyping_protocol_name))
      files=c(files, file$basename)
      files_info[[file$basename]] = file
      index=index+1
    }
  }
  if ( length(files) < 1 ) {
    stop("No archived VCF files found")
  }

  # Have user select file to download
  selection = NA
  while ( is.na(selection) || selection < 1 || selection > length(files) ) {
    selection = as.numeric(readline(prompt="--> Enter file number: "));
  }

  # Download the selected file
  selected_basename=files[[selection]]
  selected_file=files_info[[selected_basename]]
  url = sprintf("%s/ajax/genotyping_project/download_archived_vcf?genotyping_project_id=%i&basename=%s", conn$base(), selected_file$genotyping_project_id, selected_file$basename)
  resp = httr::GET(url, httr::write_disk(output, overwrite=TRUE), httr::timeout(3600))
  httr::warn_for_status(resp)
  if ( verbose ) {
    cat(
      sprintf("Response [GET] <%s>", resp$url),
      sprintf("  %s", httr::http_status(resp)$message),
      sprintf("  Project: %s (%i)", selected_file$genotyping_project_name, selected_file$genotyping_project_id),
      sprintf("  Protocol: %s (%i)", selected_file$genotyping_protocol_name, selected_file$genotyping_protocol_id),
      sprintf("  Basename: %s", selected_file$basename),
      sprintf("  Output File: %s", output),
      sep = "\n"
    )
  }

  return(list(
    response = resp,
    status = httr::http_status(resp),
    content = output,
    data = output
  ))
}


#
# Get Breedbase Imputed VCF File
#
# Get the available imputed VCF files based on the provided project
# Get project info for the selected project
# Get protocol info for the selected project
# Check to see if an imputed dataset is available
# Download the project's imputed VCF file to the specified output
#
BreedbaseRequestImputedVCF <- function(conn, output, genotyping_project_id = NULL, verbose = FALSE) {
  
  # A project is required
  if ( is.null(genotyping_project_id) ) {
    stop("A genotyping project is required")
  }

  # Get the project name
  if ( verbose ) print(sprintf("--> Getting project name for project [id = %i]", genotyping_project_id))
  projects = conn$wizard("genotyping_projects")
  genotyping_project_name = projects$data$names[which(projects$data$ids == genotyping_project_id)]
  if ( length(genotyping_project_name) == 0 ) {
    stop(sprintf("Genotyping Project not found for project id %i", genotyping_project_id))
  }

  # Get the corresponding protocol
  if ( verbose ) print(sprintf("--> Getting matching protocol for project [id = %i]", genotyping_project_id))
  protocols = conn$wizard("genotyping_protocols", list(genotyping_projects = c(genotyping_project_id)))
  if ( length(protocols$data$ids) == 0 ) {
    stop(sprintf("No matching Genotyping Protocol found for project id %i", genotyping_project_id))
  }
  if ( length(protocols$data$ids) > 1 ) {
    stop(sprintf("More than 1 matching Genotyping Protocols found for project id %i", genotyping_project_id))
  }

  # Get the project's organisms and their genera
  if ( verbose ) print(sprintf("--> Getting matching organisms for project [id = %i]", genotyping_project_id))
  organisms = conn$wizard("organisms", list(genotyping_projects = c(genotyping_project_id)))
  if ( length(organisms$data$names) == 0 ) {
    stop(sprintf("No matching Organisms found for project id %i", genotyping_project_id))
  }
  genera = unique(gsub(" .*", '', organisms$data$names))
  if ( length(genera) == 0 ) {
    stop(sprintf("No matching genera found for project id %i", genotyping_project_id))
  }
  if ( length(genera) > 1 ) {
    stop(sprintf("More than 1 matching genera found for project id %i [%s]", genotyping_project_id, paste(genera, collapse=", ")))
  }

  # Generate URL for imputed VCF
  url = paste(
    paste(
      gsub("://[^.]+", "://files", conn$base()),
      "download",
      genera[1],
      protocols$data$ids[1],
      genotyping_project_name,
      sep="/"
    ),
    "vcf.gz",
    sep = "."
  )
  if ( verbose ) print(sprintf("--> Download URL: %s", url))

  # Check for presence of file
  resp = httr::HEAD(url, httr::timeout(3600))
  if ( verbose ) {
    cat(
      sprintf("Response [HEAD] <%s>", resp$url),
      sprintf("  %s", httr::http_status(resp)$message),
      sprintf("  Project: %s (%i)", genotyping_project_name, genotyping_project_id),
      sprintf("  Protocol: %s (%i)", protocols$data$names[1], protocols$data$ids[1]),
      sprintf("  Species: %s", genera[1]),
      sep = "\n"
    )
  }
  if ( resp$status != 200 ) {
    stop(sprintf("No imputed data found for project id %i [%s]", genotyping_project_id, http_status(resp$status)$reason))
  }

  # Download file, if found
  resp = httr::GET(url, httr::write_disk(output, overwrite=TRUE), httr::timeout(3600))
  httr::warn_for_status(resp)
  if ( verbose ) {
    cat(
      sprintf("Response [GET] <%s>", resp$url),
      sprintf("  %s", httr::http_status(resp)$message),
      sprintf("  Project: %s (%i)", genotyping_project_name, genotyping_project_id),
      sprintf("  Protocol: %s (%i)", protocols$data$names[1], protocols$data$ids[1]),
      sprintf("  Species: %s", genera[1]),
      sprintf("  Output File: %s", output),
      sep = "\n"
    )
  }
}