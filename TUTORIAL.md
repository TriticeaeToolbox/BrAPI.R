# T3/Wheat Tutorial

This Tutorial uses the `BrAPI` R package to query the T3/Wheat Breedbase database for trials, phenotype data, and genotype data.  The same functions should work the same for any BrAPI-compliant database (using v2 of the BrAPI specification).

## Setup

With the `BrAPI` R packages installed, create a connection to the database.

```R
wheat <- getBrAPIConnection("T3/Wheat")
```

## Breeding Programs

If you're guiding a user to select specific Trials, you might want to allow them to select a Breeding Program first to filter the number of trials they can select from.

```R
resp <- wheat$get("/programs", page="all")
programs <- sort(sapply(resp$combined_data, \(x) { x$programName }))
```

## Trials

If you want to give the user a list of trials to choose from, you can get a list of trial names and ids filtered by a selected breeding program:

```R
selected_breeding_program <- "University of Nebraska"
resp <- wheat$get("/studies", query=list(programName=selected_breeding_program), page="all")
trials <- sort(sapply(resp$combined_data, \(x) { x$studyName }))
```

## Trial Metadata

Once you have the trials you are interested in, you can get the trial metadata (such as trial location, design type, planting/harvest dates, year, etc):

```R
selected_trials <- c("YldQtl-Val_2014_ClayCenter", "YldQtl-Val_2014_Lincoln", "YldQtl-Val_2014_Mead", "YldQtl-Val_2014_Sidney")
for ( trial_name in selected_trials ) {
  resp <- wheat$get("/studies", query=list(studyName=trial_name))
  trial_metadata <- resp$data[[1]]
  location <- trial_metadata$locationName
  planting_date <- trial_metadata$startDate
  harvest_date <- trial_metadata$endDate
  design <- trial_metadata$experimentalDesign$PUI
}
```
