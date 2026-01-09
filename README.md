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

### Tutorial

A more in-depth tutorial using data from T3/Wheat can be found in the TUTORIAL.md file.


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
This package includes some breedbase-specific helper functions (such as programatically using the Search Wizard) that are only available for breedbase BrAPI instances.  When using the `createBrAPIConnection()` function, add the `is_breedbase=TRUE` argument to enable the breedbase-specific functions.

```R
wheat <- createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase=TRUE)
```

When using the known connections via the `getBrAPIConnection()` function, the `is_breedbase` argument will automatically be added for breedbase connections.

## Authorization

Some databases may require authorization for all or some endpoints (such as those that are used to add or update data in the database).  Since authorization methods have not been standardized across all BrAPI databases, each database may handle it slighly differently - please refer to the documentation of the BrAPI database or tool you're trying to connect to for details.

This package assumes that authorization is handled by adding a `Authorization: Bearer {token}` header to the requests.

### Breedbase Databases

If you're connecting to a breedbase database, you can use the BrAPI Connection's `login(username, password)` function to get an authorization token that will be used in all future requests for that connection.  Alternatively, you can use the `login()` function without the username and password and you will be prompted to enter your username and password when the function is called.

The `login()` function will send a `POST` request to the the `/token` endpoint with your username and password to retrieve and save a new authorization token.

```R
wheat$login("myusername", "mypassword") # if successful, this saves an authorization token 
wheat$get("/germplasm") # this request will automatically have the authorization token added to it, you don't need to do anything differently
```

### Other Databases

If you're connecting to a non-breedbase database that requires authorization, you will need to manually request an authorization token. Once you have it, you can use the `login(token = "myAuthToken")` function to save the token for future requests.

```R
wheat$login(token = "myAuthToken") # this will store your auth token as-is for future requests
wheat$get("/germplasm") # this request will automatically have the authorization token added to it, you don't need to do anything differently
``` 

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

### Search Function
The [conn$search() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-search) is a helper function that can be used to perform a BrAPI two-step search.  This function will make the initial request to the `/search/{datatype}` endpoint.  If that is successful, it will then automatically fetch all of the results from the `/search/{datatype}/{searchResultsDbId}` endpoint.

For example, to search for and retrieve all of the observations from a specific trial:

```R
wheat <- getBrAPIConnection("T3/Wheat")
results <- wheat$search("/observations", body = list(studyDbIds = c(7459)))
# results$combined_data will contain all of the search results
```

## Breedbase Functions

This package includes some breedbase-specific helper functions for performing some non-BrAPI compliant tasks that are available on breedbase.  The `BrAPIConnection` object needs to have the `is_breedbase` argument set to `TRUE` in order for these functions to be enabled.

- [conn$wizard() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-wizard) - filter data using the breedbase Search Wizard
- [conn$vcf() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-vcf) - download a breedbase-generated VCF file for a genotyping protocol, optionally filtered by accessions
- [conn$vcf_archive() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-vcf_archived) - download a static, archived VCF for an entire genotyping project
- [conn$vcf_imputed() function](https://triticeaetoolbox.github.io/BrAPI.R/reference/BrAPIConnection.html#method-BrAPIConnection-vcf_imputed) - download a static VCF of imputed data for an imputed genotyping project (not all genotyping projects have been imputed)

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

Depending on the size of the genotyping protocol (number of markers) and the number of accessions to download, **this download function may still take a long time to download**.  If the function times out, you may want to try to download an archived VCF file of the data.

### Downloading Archived VCF Files: `conn$vcf_archived(output, genotyping_protocol_id, genotyping_project_id, file_name)`

This function will allow you to download a static, archived VCF file for a specific genotyping project, when available.  These files are the original VCF files that were used to upload the data to the database.

The archived files are saved at the project level.  So, if you specify a protocol, you'll get a list of all of the available files for each project in that protocol and you can select which one to download.  If you're performing analysis at the protocol level, you'll need to manually merge the VCF files from each project in that protocol.

```R
> wheat <- getBrAPIConnection("T3/Wheat")
> resp <- wheat$vcf_archived("~/Desktop/my_data.vcf", genotyping_protocol_id=297)
Finding archived VCF files...
  Genotyping Protocol: 297
Found 4 files...
--> Select a file to download:
[#] Project Name (Protocol Name) [File Name]
--------------------------------------------
[1] Allegro V1 tempate (Allegro V1) [2025-09-03_18:51:07_fileuEjk]
[2] KSU_2023_Allegro (Allegro V1) [2025-09-03_19:07:44_fileFJaf]
[3] KSU_2023_Allegro_AeTa (Allegro V1) [2025-09-03_19:28:16_filee3Si]
[4] UCD_2020_Allegro (Allegro V1) [2025-09-03_18:53:02_filepq5P]
--> Enter file number: 4
Response [GET] <https://wheatcap.triticeaetoolbox.org/ajax/genotyping_project/download_archived_vcf?genotyping_project_id=10371&basename=2025-09-03_18:53:02_filepq5P>
  Success: (200) OK
  Protocol: Allegro V1 (297)
  Project: UCD_2020_Allegro (10371)
  File Name: 2025-09-03_18:53:02_filepq5P
  Output File: ~/Desktop/my_data.vcf
```

If you know which file you want to download, you can add the archived file's file name as the `file_name` argument to the `vcf_archived()` function.  When there is only one matching file, that file will be automatically downloaded to the output file (you won't be prompted to select a file).

If you want to get a table of available files before requesting a download, you can do so with the `vcf_archived_list()` function, which also takes a `genotyping_protocol_id` and/or `genotyping_project_id` as arguments.  This will return a data frame with the protocol id and name, project id and name, and file name of the available archived files for your request.  You can then use one of the returned file names as the `file_name` argument in the `vcf_archived()` download function.

```R
> files <- wheat$vcf_archived_list(genotyping_protocol_id=297, verbose=T)
Finding archived VCF files...
  Genotyping Protocol: 297
Found 4 files...
> files
  protocol_id protocol_name project_id          project_name                    file_name
1         297    Allegro V1      13533    Allegro V1 tempate 2025-09-03_18:51:07_fileuEjk
3         297    Allegro V1      11359      KSU_2023_Allegro 2025-09-03_19:07:44_fileFJaf
4         297    Allegro V1      13534 KSU_2023_Allegro_AeTa 2025-09-03_19:28:16_filee3Si
2         297    Allegro V1      10371      UCD_2020_Allegro 2025-09-03_18:53:02_filepq5P
> resp <- wheat$vcf_archived("~/Desktop/geno_data.vcf", genotyping_protocol_id=297, file_name="2025-09-03_19:07:44_fileFJaf", verbose=T)
Finding archived VCF files...
  Genotyping Protocol: 297
Found 4 files...
Response [GET] <https://wheatcap.triticeaetoolbox.org/ajax/genotyping_project/download_archived_vcf?genotyping_project_id=11359&basename=2025-09-03_19:07:44_fileFJaf>
  Success: (200) OK
  Protocol: Allegro V1 (297)
  Project: KSU_2023_Allegro (11359)
  File Name: 2025-09-03_19:07:44_fileFJaf
  Output File: ~/Desktop/geno_data.vcf
```