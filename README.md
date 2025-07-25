BrAPI.R
=======

This R package contains a simple R6 Class for interacting with a BrAPI server.  It holds all of the information needed to connect to a server (such as the hostname) and has helper functions for making an HTTP requests to the BrAPI server.

It does not have any knowledge of the currently supported BrAPI endpoints.  You'll need to refer to the [BrAPI specification](https://brapi.org/specification) to know which endpoints to use and how the response will be formatted.

```R
# Get a BrAPI Connection
wheat <- getBrAPIConnection("T3/Wheat")

# Get Studies associated with the Cornell breeding program
resp <- wheat$get("/studies", query=list(programName="Cornell University"), pageSize=1000)
studies <- resp$data
 
# Get all Germplasm stored in the database
resp <- wheat$get("/germplasm", page="all", pageSize=5000)
germplasm <- resp$combined_data
```

## Installation

This package can be installed directly from GitHub, using the `devtools` package.

```R
# Install devtools, if you haven't already
install.packages("devtools")

# Install the BrAPI package from GitHub
library(devtools)
install_github("TriticeaeToolbox/BrAPI.R")
library(BrAPI)
```

## Documentation

Reference Documentation can be found here: [https://triticeaetoolbox.github.io/BrAPI.R](https://triticeaetoolbox.github.io/BrAPI.R)


## Creating a BrAPI Connection

The [BrAPIConnection Class](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html) contains information about the BrAPI server and has helper functions for making HTTP requests.

There are some known pre-configured BrAPI connections included with this package.  To see the list of known BrAPI connections, use the [listBrAPIConnections() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/listBrAPIConnections.html):

```R
listBrAPIConnections()
# PRINTS:
# Known BrAPI Connections:
#  T3/Wheat = wheat.triticeaetoolbox.org [v2]
#  T3/Wheat Sandbox = wheat-sandbox.triticeaetoolbox.org [v2]
#  T3/Oat = oat.triticeaetoolbox.org [v2]
#  T3/Oat Sandbox = oat-sandbox.triticeaetoolbox.org [v2]
#  T3/Barley = barley.triticeaetoolbox.org [v2]
#  T3/Barley Sandbox = barley-sandbox.triticeaetoolbox.org [v2]
#  Cassavabase = cassavabase.org [v2]
```

To use a known BrAPI connection, reference it by name in the [getBrAPIConnection() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/getBrAPIConnection.html):
```R
wheat <- getBrAPIConnection("T3/Wheat")
```

To manually create a BrAPI connection, you'll need to specify the host of the BrAPI server (and optionally set the protocol, path, and/or version) in the [createBrAPIConnection() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html):

```R
kelp <- createBrAPIConnection("sugarkelpbase.org")
kelpv1 <- createBrAPIConnection("sugarkelpbase.org", version="v1")
```

### Breedbase Connections
This package includes some breedbase-specific helper functions (such as pragmatically using the Search Wizard) that are only available for breedbase BrAPI instances.  When using the `createBrAPIConnection()` function, add the `is_breedbase=TRUE` argument to enable the breedbase-specific functions.

```R
wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase=TRUE)
```

When using the known connections via the `getBrAPIConnection()` function, the `is_breedbase` argument will automatically be added for breedbase connections.

## Making HTTP Requests

Once you have a `BrAPIConnection` object, you can use it to make HTTP Requests to the BrAPI server.  There is a separate helper function for each type of HTTP request.

- [conn$get() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-get) - to make a GET request
- [conn$post() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-post) - make a POST request
- [conn$put() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-put) - make a PUT request

### Request Parameters

Each of the request functions (`get`, `post`, `put`) can take the following parameters:

- `call` - The BrAPI endpoint to make the request to
- `query` - (optional) A named list of query parameters
- `body` - (optional) A named list or vector of body parameters (this will be automatically converted to JSON)
- `page` - (optional) the index of the page of results to return (DEFAULT: 0)
  - When `page="all"`, all of the available pages will be fetched sequentially and the response properties of all of the individual pages along with the combined data from all of the pages will be returned
- `pageSize` - (optional) the maximum size of the page of results to return (DEFAULT: 10)

### Response Format

The return value for each of the request functions (`get`, `post`, `put`) will return a named list containing the properties of the Response.

For a singe-page request:

- `response` - the `httr` response object
- `status` - the parsed HTTP status
- `content` - the full content of the body of the response
- `metadata` - the metadata object from the body of the reponse, if returned
- `data` - the data object from the body of the response, if returned

For a multi-page request (when `page="all"`):

- `response` - a list of the `httr` response object by page
- `status` - a list of the parsed HTTP status by page
- `content` - a list of the full content of the body of the response by page
- `metadata` - a list of the metadata object from the body of the response by page, if returned
- `data` - a list of the data object from the body of the response by page, if returned
- `combined_data` - a combined vector of the data from all of the pages, if returned

### Examples

```R
# GET Request
wheat <- getBrAPIConnection("T3/Wheat")
resp <- wheat$get("/studies", query=list(programName="Cornell University"))

# POST Request
sandbox <- createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org")
d1 <- list(observationUnitDbId="ou1", observationVariableDbId="ov1", value=50)
d2 <- list(observationUnitDbId="ou2", observationVariableDbId="ov1", value=40)
data <- list(d1, d2)
resp <- sandbox$post("/token", query=list(username="testing", password="testing123"))
resp <- sandbox$post("/observations", body=data, token=resp$content$access_token)

# PUT Request
sandbox <- createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org")
d1 <- list(observationDbId = "ob1", observationUnitDbId="ou1", observationVariableDbId="ov1", value=60)
d2 <- list(observationDbId = "ob2", observationUnitDbId="ou2", observationVariableDbId="ov1", value=70)
data <- list(d1, d2)
resp <- sandbox$post("/token", query=list(username="testing", password="testing123"))
resp <- sandbox$put("/observations", body=data, token=resp$content$access_token)
```

## Breedbase Functions

This package includes some breedbase-specific helper functions for performing some non-BrAPI compliant tasks that are available on breedbase.  The `BrAPIConnection` object needs to have the `is_breedbase` argument set to `TRUE` in order for these functions to be enabled.

### Search Wizard: `conn$wizard(data_type, filters, verbose)`

The breedbase Search Wizard is a great tool for quickly filtering and combining datasets in the database.  You can use it to request data of a specific data type that matches specified filter criteria.  The filter criteria can be specified by either the IDs or the names of the items.  However, if you use names, the function will perform additional queries to lookup the IDs for the named items.  If you already have the IDs, it is better to use those.

For example, you can use it to find the genotyping protocols that have data from a set of accessions that were observed in a set of field trials.

```R
wheat <- getBrAPIConnection("T3/WheatCAP")

# Find accessions that were observed in these two trials
accessions <- wheat$wizard("accessions", list(trials = c("CornellMaster_2024_Helfer", "CornellMaster_2025_McGowan")), verbose=T)

# Get genotyping protocols that have data for any of the trial's accessions
geno <- wheat$wizard("genotyping_protocols", list(accessions = accessions$data$ids))
```

The Search Wizard response data will include the ids, names, and a map of names -> ids for the matching data:

```R
> geno$data$ids
[1] 265 287 130 242

> geno$data$names
[1] "GBS Cornell 2024"  "GBS Cornell 2025"  "GBS CornellMaster"  "GBS MSU"

> geno$data$map
$`GBS Cornell 2024`
[1] 265

$`GBS Cornell 2025`
[1] 287

$`GBS CornellMaster`
[1] 130

$`GBS MSU`
[1] 242
```

The `filters` argument can contain up to 3 different filters. The name of the list item is one of the supported breedbase data types: accessions, organisms, breeding_programs, genotyping_protocols, genotyping_projects, locations, plants, plots, tissue_sample, seedlots, trait_components, traits, trials, trial_designs, trial_types, years

```R
# Find all trials from these two breeding programs from one year
trials <- wheat$wizard("trials", list(breeding_programs = c(327,367), years = c(2023)))
```

### Downloading VCF Files: `conn$vcf(output, genotyping_protocol_id, accessions)`

If the BrAPI genotyping endpoints are too slow, you can try downloading VCF files of the genotyping data using the internal breedbase endpoints that are used to download genotyping data from the Search Wizard.  To use the `conn$vcf()` function, you'll need to provide the path to the output file where the VCF file will be saved on your computer, the database id of the genotyping protocol, and (optionally) a list of database ids of accessions to use as a filter on the genotype data.

To download an entire genotyping protocol:

```R
wheat <- getBrAPIConnection("T3/WheatCAP")
wheat$vcf("~/Desktop/my_data.vcf", genotyping_protocol_id = 249)
```

To download a subset of accessions from a genotyping protocol:

```R
wheat <- getBrAPIConnection("T3/WheatCAP")
wheat$vcf("~/Desktop/my_data.vcf", genotyping_protocol_id = 249, accessions = c(228677, 1666408))
```

Depending on the size of the genotyping protocol (number of markers) and the number of accessions to download, **this download function may still take a long time to download**.  If the function timesout, you may want to try to download an archived VCF file of the data.

### Downloading Archived VCF Files: `conn$vcf_archived(output, genotyping_protocol_id, genotyping_project_id)`

This function will allow you to download a static, archived VCF file for a specific genotyping project, when available.  These files are the original VCF files that were used to upload the data to the database.

The archived files are saved at the project level.  So, if you specify a protocol, you'll get a list of all of the available files for each project in that protocol and you can select which one to download.  If you're performing analysis at the protocol level, you'll need to manually merge the VCF files from each project in that protocol.

```R
> wheat <- getBrAPIConnection("T3/WheatCAP")
> resp <- wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_protocol_id=233)
Finding archived VCF files...
--> Select a file to download:
[1] UCD_2020_Allegro (Allegro)
[2] KSU_2023_Allegro (Allegro)
--> Enter file number: 1
Response [GET] <https://wheatcap.triticeaetoolbox.org/ajax/genotyping_project/download_archived_vcf?genotyping_project_id=11359&basename=2024-06-13_14:25:50_23GUT_FIN.vcf>
  Success: (200) OK
  Project: KSU_2023_Allegro (11359)
  Protocol: Allegro (233)
  Basename: 2024-06-13_14:25:50_23GUT_FIN.vcf
  Output File: ~/Desktop/my_data.vcf
```

## Tutorial

A more in-depth tutorial using data from T3/Wheat can be found in the TUTORIAL.md file.
