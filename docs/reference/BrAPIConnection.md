# BrAPI Connection Class

BrAPI Connection Class

BrAPI Connection Class

## Details

An R6 Class representing a connection to a BrAPI server.

This Class provides all of the information needed for connecting to a
BrAPI server. The host field is required. For all other fields, the
default value will be used if one is not provided. Add the
`is_breedbase=TRUE` argument to enable breedbase-specific functions.

This Class also provides helper functions for making requests to the
BrAPI server. Use `conn$get()` to make a GET request, `conn$post()` to
make a POST request, and `conn$put()` to make a PUT request.

The return value of a request function contains a named list with the
properties of the Response(s).

For a singe-page request:

- `response` = the `httr` response object

- `status` = the parsed HTTP status

- `content` = the full content of the body of the response

- `metadata` = the metadata object from the body of the reponse, if
  returned

- `data` = the data object from the body of the response, if returned

For a multi-page request (when `page="all"`):

- `response` = a list of the `httr` response object by page

- `status` = a list of the parsed HTTP status by page

- `content` = a list of the full content of the body of the response by
  page

- `metadata` = a list of the metadata object from the body of the
  response by page, if returned

- `data` = a list of the data object from the body of the response by
  page, if returned

- `combined_data` = a combined vector of the data from all of the pages,
  if returned

## Public fields

- `protocol`:

  The HTTP protocol - either 'http' or 'https' (Default: `https`)

- `host`:

  The hostname of the BrAPI server

- `path`:

  The base bath of the BrAPI endpoints (not including the version)
  (Default: `/brapi/`)

- `version`:

  The BrAPI version (such as 'v1' or 'v2') (Default: `v2`)

- `is_breedbase`:

  A flag to indicate this BrAPI connection is to a breedbase instance.
  This adds additional support for breedbase-specific functionality.
  (Default: `FALSE`)

- `auth_token`:

  An auth token that will be passed as a Bearer Token in the the
  Authorization header to all requests

## Methods

### Public methods

- [`BrAPIConnection$new()`](#method-BrAPIConnection-new)

- [`BrAPIConnection$base()`](#method-BrAPIConnection-base)

- [`BrAPIConnection$login()`](#method-BrAPIConnection-login)

- [`BrAPIConnection$get()`](#method-BrAPIConnection-get)

- [`BrAPIConnection$post()`](#method-BrAPIConnection-post)

- [`BrAPIConnection$put()`](#method-BrAPIConnection-put)

- [`BrAPIConnection$search()`](#method-BrAPIConnection-search)

- [`BrAPIConnection$wizard()`](#method-BrAPIConnection-wizard)

- [`BrAPIConnection$vcf()`](#method-BrAPIConnection-vcf)

- [`BrAPIConnection$vcf_archived_list()`](#method-BrAPIConnection-vcf_archived_list)

- [`BrAPIConnection$vcf_archived()`](#method-BrAPIConnection-vcf_archived)

- [`BrAPIConnection$vcf_imputed()`](#method-BrAPIConnection-vcf_imputed)

- [`BrAPIConnection$clone()`](#method-BrAPIConnection-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new `BrAPIConnection` object

#### Usage

    BrAPIConnection$new(
      host,
      protocol = "https",
      path = "/brapi/",
      version = "v2",
      is_breedbase = FALSE,
      auth_token = NULL
    )

#### Arguments

- `host`:

  (required) The hostname of the BrAPI server

- `protocol`:

  (optional) The HTTP protocol - either 'http' or 'https'

- `path`:

  (optional) The base path of the BrAPI endpoints

- `version`:

  (optional) The BrAPI version

- `is_breedbase`:

  (optional) set to TRUE if the connection is to a breedbase instance

- `auth_token`:

  (optional) set the Auth Token when creating the connection

#### Returns

`BrAPIConnection` object

------------------------------------------------------------------------

### Method `base()`

Generate the base URL of the connection

#### Usage

    BrAPIConnection$base()

#### Returns

A String in the format `$protocol://$host`

------------------------------------------------------------------------

### Method `login()`

Login to the server to set an auth token for all future requests.

If a username and password are provided, a POST request will be made to
the /token endpoint with your username and password to request a new
auth token. If a token is provided, then that will be saved and used
as-is in future requests. If none are provided, the user will be
prompted for their username and password

#### Usage

    BrAPIConnection$login(username = NULL, password = NULL, token = NULL)

#### Arguments

- `username`:

  (optional) Your account username for the database

- `password`:

  (optional) Your account password for the database

- `token`:

  (optional) An auth token to use in all future requests to this
  database

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Make a GET request

#### Usage

    BrAPIConnection$get(call, ...)

#### Arguments

- `call`:

  The BrAPI endpoint to request

- `...`:

  (optional) Additional arguments passed to `httr`

- `query`:

  (optional) A named list of query parameters

- `page`:

  (optional) The index of the page of results (use 'all' to get all
  pages) (Default: 0)

- `pageSize`:

  (optional) The max size of the result pages (Default: 10)

- `token`:

  (optional) An Authorization token to add to the request

- `verbose`:

  (optional) Set to true to include additional output to the console
  about the Response

#### Returns

A named list of Response properties

#### Examples

    # Making a GET request
    resp <- wheat$get("/germplasm", pageSize=100)
    resp <- wheat$get("/studies", pageSize=1000, page="all")
    resp <- wheat$get("/studies", query=list(programName="Cornell University"), pageSize=1000)

------------------------------------------------------------------------

### Method `post()`

Make a POST request

#### Usage

    BrAPIConnection$post(call, ...)

#### Arguments

- `call`:

  The BrAPI endpoint to request

- `...`:

  (optional) Additional arguments passed to `httr`

- `query`:

  (optional) A named list of query parameters

- `body`:

  (optional) A named list or vector of the request body (will be
  converted to JSON)

- `page`:

  (optional) The index of the page of results (use 'all' to get all
  pages) (Default: 0)

- `pageSize`:

  (optional) The max size of the result pages (Default: 10)

- `verbose`:

  (optional) Set to true to include additional output to the console
  about the Response

#### Returns

A named list of Response properties

#### Examples

    # Make a POST request
    \dontrun{
    sandbox <- BrAPIConnection$new("wheat-sandbox.triticeaetoolbox.org")
    d1 <- list(observationUnitDbId="ou1", observationVariableDbId="ov1", value=50)
    d2 <- list(observationUnitDbId="ou2", observationVariableDbId="ov1", value=40)
    data <- list(d1, d2)
    sandbox$login(username = "testing", password = "testing123")
    resp <- sandbox$post("/observations", body=data)
    }

------------------------------------------------------------------------

### Method `put()`

Make a PUT request

#### Usage

    BrAPIConnection$put(call, ...)

#### Arguments

- `call`:

  The BrAPI endpoint to request

- `...`:

  (optional) Additional arguments passed to `httr`

- `query`:

  (optional) A named list of query parameters

- `body`:

  (optional) A named list or vector of the request body (will be
  converted to JSON)

- `page`:

  (optional) The index of the page of results (use 'all' to get all
  pages) (Default: 0)

- `pageSize`:

  (optional) The max size of the result pages (Default: 10)

- `verbose`:

  (optional) Set to true to include additional output to the console
  about the Response

#### Returns

A named list of Response properties

------------------------------------------------------------------------

### Method [`search()`](https://rdrr.io/r/base/search.html)

Make a BrAPI Search request.

This function performs the two-step BrAPI search request, first making a
POST request to the /search/datatype endpoint and then automatically
fetches all of the search results from the
/search/datatype/searchResultsDbId endpoint.

The call parameter should be the supported /search/datatype endpoint
(such as /search/observations). You can omit the /search prefix and it
will automatically be added

You should include any of your search filters as the body to the
request.

If the initial /search/datatype is successful, this function will
automatically request the /search/datatype/searchResultDbId with page =
'all' set to return all of the returned search results.

#### Usage

    BrAPIConnection$search(call, ...)

#### Arguments

- `call`:

  The BrAPI search endpoint to request (such as /search/observations or
  just /observations)

- `...`:

  (optional) Additional arguments passed to `httr`

- `query`:

  (optional) A named list of query parameters

- `body`:

  (optional) A named list or vector of the request body (will be
  converted to JSON)

- `page`:

  (optional) The index of the page of results (use 'all' to get all
  pages) (Default: 0)

- `pageSize`:

  (optional) The max size of the result pages (Default: 10)

- `verbose`:

  (optional) Set to true to include additional output to the console
  about the Response

#### Returns

A named list of Response properties

------------------------------------------------------------------------

### Method `wizard()`

Make a Breedbase Search Wizard request.

This function returns all of the items of the specified data type,
filtered by the data types and items included in the filters argument.
For example, you can use this to find all field trials from a set of
breeding programs in a specific year. If you don't provide any filters,
the function will return the full set of all items in the database for
the data type. The results only include the database IDs and names of
the matching items. You can use the IDs in the general BrAPI endpoints
to get additional data about the items.

#### Usage

    BrAPIConnection$wizard(data_type, filters = list(), verbose = FALSE)

#### Arguments

- `data_type`:

  The data type to return after filtering

- `filters`:

  A list of the filters (up to 3) to apply to the search. The key should
  be the name of the data type and the value should be a vector of
  database ids or names of the items to include in the filter.

  It is better to use IDs if you have them - when you use names, the
  function will make additional queries to lookup the IDs for the names
  you provide.

  Supported data types include: accessions, organisms,
  breeding_programs, genotyping_protocols, genotyping_projects,
  locations, plants, plots, tissue_sample, seedlots, trait_components,
  traits, trials, trial_designs, trial_types, years

- `verbose`:

  Set to TRUE to include logging information

#### Returns

A response with the matching data. The \$content key contains the raw
breedbase response. The \$data key contains parsed data: a list parsed
into `ids`, `names` and `map` (a named list of item names -\> ids)

#### Examples

    wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase = TRUE)

    # find matching trials, filtered by two breeding programs (identified by ids) and one year
    trials <- wheat$wizard("trials", list(breeding_programs = c(327,367), years = c(2023)))

    # find matching accessions, filtered by field trials (identified by name)
    accessions <- wheat$wizard("accessions", list(trials = c("CornellMaster_2024_Helfer", "CornellMaster_2025_McGowan")))

    # find genotyping protocols that have data for the above set of accessions
    geno_protocols <- wheat$wizard("genotyping_protocols", list(accessions = accessions$data$ids))

------------------------------------------------------------------------

### Method `vcf()`

Download a Breedbase VCF File

NOTE: Depending on the number of markers and accessions, this download
may take a very long time to complete. You may want to use the
conn\$vcf_archived() function to download a static archived VCF file of
a genotyping project, if one is available.

#### Usage

    BrAPIConnection$vcf(
      output,
      genotyping_protocol_id,
      accessions = NULL,
      verbose = FALSE
    )

#### Arguments

- `output`:

  The path to the output VCF file

- `genotyping_protocol_id`:

  The Database ID of the genotyping protocol to download

- `accessions`:

  (optional) A list of Accession Database IDs to use as a filter for the
  VCF data

- `verbose`:

  Set to TRUE to include logging information

#### Returns

Status information about the request. If successful, the genotype data
will be downloaded to the VCF file specified by the output argument.

#### Examples

    \dontrun{
    wheat <- getBrAPIConnection("T3/Wheat")
    wheat$vcf("~/Desktop/my_data.vcf", genotyping_protocol_id = 249)
    wheat$vcf("~/Desktop/my_data.vcf", genotyping_protocol_id = 249, accessions = c(228677, 1666408))
    }

------------------------------------------------------------------------

### Method `vcf_archived_list()`

List all of the available Archived Breedbase VCF Files

This function will return a table with all of the archived VCF files
available for the specified protocol and/or project. The file_name can
be used to specify the specific file to download when using the
`vcf_archived` function.

The archived files are saved at the project-level. So, if you specify a
protocol, you'll get a list of all of the available files for each
project in that protocol. If you're performing analysis at the
protocol-level, you'll need to manually merge the VCF files from each
project in that protocol.

#### Usage

    BrAPIConnection$vcf_archived_list(
      genotyping_protocol_id = NULL,
      genotyping_project_id = NULL,
      verbose = FALSE
    )

#### Arguments

- `genotyping_protocol_id`:

  The Database ID of the genotyping protocol

- `genotyping_project_id`:

  The Database ID of the genotyping project

- `verbose`:

  Set to TRUE to include logging information

#### Returns

a Data Frame with the protocol and project information for each
available archived file

#### Examples

    \dontrun{
    wheat <- getBrAPIConnection("T3/Wheat")
    files <- wheat$vcf_archived_list(genotyping_protocol_id=70)
    files <- wheat$vcf_archived_list(gentyping_project_id=2761)
    }

------------------------------------------------------------------------

### Method `vcf_archived()`

Download an Archived Breedbase VCF File

This function will download an archived VCF file from the server to the
specified output file. You must specify either a genotyping protocol
and/or a genotyping project by id. You may also specify the file name of
the specific archived file you want to download. If you don't specify
the archived file's file_name, a list of all of the available files will
be displayed for you to choose from. You can also get a table of all of
the available archived files from the `vcf_archived_list` function.

#### Usage

    BrAPIConnection$vcf_archived(
      output,
      genotyping_protocol_id = NULL,
      genotyping_project_id = NULL,
      file_name = NULL,
      verbose = FALSE
    )

#### Arguments

- `output`:

  The path to the output VCF file

- `genotyping_protocol_id`:

  The Database ID of the genotyping protocol

- `genotyping_project_id`:

  The Database ID of the genotyping project

- `file_name`:

  The name of the specific archived file to download (if not provided,
  all of the available files will be listed for you to choose from)

- `verbose`:

  Set to TRUE to include logging information

#### Returns

Status information about the request. If the download of an available
archived VCF file is successful, the genotype data will be downloaded to
the VCF file specified by the output argument.

#### Examples

    \dontrun{
    wheat <- getBrAPIConnection("T3/Wheat")
    wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_protocol_id=70)
    wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_project_id=2761)
    wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_protocol_id=70, file_name="2019-12-30_16:33:07_TCAP90K_HWWAMP.vcf")

    }

------------------------------------------------------------------------

### Method `vcf_imputed()`

Download an Imputed VCF File

This function will download an imputed dataset for the selected
genotyping project (if available). The genotype projects have been
imputed using the Practical Haplotype Graph (PHG). The imputed marker
density is 2.9M markers for assembly RefSeq v2.1. For quick access the
imputed genotypes can be downloaded from a prepared file. A description
of the imputation process can be found in About PHG imputation
(https://wheat.triticeaetoolbox.org/static_content/files/imputation.html).

#### Usage

    BrAPIConnection$vcf_imputed(
      output,
      genotyping_project_id = NULL,
      verbose = FALSE
    )

#### Arguments

- `output`:

  The path to the output VCF file

- `genotyping_project_id`:

  The Database ID of the genotyping project

- `verbose`:

  Set to TRUE to include logging information

#### Returns

Status information about the request. If the download of an available
imputed VCF file is successful, the genotype data will be downloaded to
the VCF file specified by the output argument.

#### Examples

    \dontrun{
    wheat <- getBrAPIConnection("T3/WheatCAP")
    wheat$vcf_imputed("~/Desktop/my_data.vcf", genotyping_project_id=10371)
    }

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    BrAPIConnection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Directly Creating a new BrAPIConnection Object
wheat <- BrAPIConnection$new("wheat.triticeaetoolbox.org", is_breedbase=TRUE)
wheatv1 <- BrAPIConnection$new("wheat.triticeaetoolbox.org", version="v1")

# Using the createBrAPIConnection function
barley <- createBrAPIConnection("barley.triticeaetoolbox.org")
barleyv1 <- createBrAPIConnection("barley.triticeaetoolbox.org", version="v1")


## ------------------------------------------------
## Method `BrAPIConnection$get`
## ------------------------------------------------

# Making a GET request
resp <- wheat$get("/germplasm", pageSize=100)
resp <- wheat$get("/studies", pageSize=1000, page="all")
resp <- wheat$get("/studies", query=list(programName="Cornell University"), pageSize=1000)

## ------------------------------------------------
## Method `BrAPIConnection$post`
## ------------------------------------------------

# Make a POST request
if (FALSE) { # \dontrun{
sandbox <- BrAPIConnection$new("wheat-sandbox.triticeaetoolbox.org")
d1 <- list(observationUnitDbId="ou1", observationVariableDbId="ov1", value=50)
d2 <- list(observationUnitDbId="ou2", observationVariableDbId="ov1", value=40)
data <- list(d1, d2)
sandbox$login(username = "testing", password = "testing123")
resp <- sandbox$post("/observations", body=data)
} # }


## ------------------------------------------------
## Method `BrAPIConnection$wizard`
## ------------------------------------------------

wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase = TRUE)

# find matching trials, filtered by two breeding programs (identified by ids) and one year
trials <- wheat$wizard("trials", list(breeding_programs = c(327,367), years = c(2023)))

# find matching accessions, filtered by field trials (identified by name)
accessions <- wheat$wizard("accessions", list(trials = c("CornellMaster_2024_Helfer", "CornellMaster_2025_McGowan")))
#> Warning: There is no matching item of type trials with the name CornellMaster_2024_Helfer

# find genotyping protocols that have data for the above set of accessions
geno_protocols <- wheat$wizard("genotyping_protocols", list(accessions = accessions$data$ids))

## ------------------------------------------------
## Method `BrAPIConnection$vcf`
## ------------------------------------------------

if (FALSE) { # \dontrun{
wheat <- getBrAPIConnection("T3/Wheat")
wheat$vcf("~/Desktop/my_data.vcf", genotyping_protocol_id = 249)
wheat$vcf("~/Desktop/my_data.vcf", genotyping_protocol_id = 249, accessions = c(228677, 1666408))
} # }

## ------------------------------------------------
## Method `BrAPIConnection$vcf_archived_list`
## ------------------------------------------------

if (FALSE) { # \dontrun{
wheat <- getBrAPIConnection("T3/Wheat")
files <- wheat$vcf_archived_list(genotyping_protocol_id=70)
files <- wheat$vcf_archived_list(gentyping_project_id=2761)
} # }

## ------------------------------------------------
## Method `BrAPIConnection$vcf_archived`
## ------------------------------------------------

if (FALSE) { # \dontrun{
wheat <- getBrAPIConnection("T3/Wheat")
wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_protocol_id=70)
wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_project_id=2761)
wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_protocol_id=70, file_name="2019-12-30_16:33:07_TCAP90K_HWWAMP.vcf")

} # }

## ------------------------------------------------
## Method `BrAPIConnection$vcf_imputed`
## ------------------------------------------------

if (FALSE) { # \dontrun{
wheat <- getBrAPIConnection("T3/WheatCAP")
wheat$vcf_imputed("~/Desktop/my_data.vcf", genotyping_project_id=10371)
} # }
```
