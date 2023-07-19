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
trials <- lapply(resp$combined_data, \(x) { list(id=x$studyDbId, name=x$studyName) })
```

## Trial Metadata

Once you have the trials you are interested in, you can get the trial metadata (such as trial location, design type, planting/harvest dates, year, etc):

```R
selected_trials <- c("YldQtl-Val_2014_ClayCenter", "YldQtl-Val_2014_Lincoln", "YldQtl-Val_2014_Mead", "YldQtl-Val_2014_Sidney")
for ( trial_name in selected_trials ) {
  resp <- wheat$get("/studies", query=list(studyName=trial_name))
  trial_metadata <- resp$data[[1]]
  trial_id <- trial_metadata$studyDbId
  location <- trial_metadata$locationName
  planting_date <- trial_metadata$startDate
  harvest_date <- trial_metadata$endDate
  design <- trial_metadata$experimentalDesign$PUI
}
```

## Trial Layout

The plot layout for a trial is defined by getting the relative plot positions.  Each plot will have a row and column position if they were assigned when the trial was added to the database.  To get the layout, you'll need to get all of the plots (observation units) from the trial and extract the row and column information:

```R
selected_trial_id <- "6104"
resp <- wheat$get("/observationunits", query=list(studyDbId=selected_trial_id), page="all", pageSize=100)
for ( plot in resp$combined_data ) {
  plot_id <- plot$observationUnitDbId
  plot_name <- plot$observationUnitName
  row <- plot$observationUnitPosition$positionCoordinateY
  col <- plot$observationUnitPosition$positionCoordinateX
  accession <- plot$germplasmName
}
```

## Traits, Accessions, and Trait Observations

The recorded trait observations are accessible from the `/observations` BrAPI endpoint.  In the response, each object in the data represents one observation (one value for a recorded trait / plot pair).  The observation contains information about the plot, accession, and trait that was observed.  The observations can be fetched for an entire trial by specifying the trial id:

```R
# Get all of the observations for a single trial
selected_trial_id <- "6104"
resp <- wheat$get("/observations", query=list(studyDbId=selected_trial_id), page="all", pageSize=500)
observations <- resp$combined_data

# Get the unique set of trait names observed in this trial
trait_names <- sort(unique(sapply(observations, \(x) { x$observationVariableName } )))

# Get the unique set of accession names in this trial
accession_names <- sort(unique(sapply(observations, \(x) { x$germplasmName } )))

# Build a long-format table of trait observations
data <- tibble(
  plot_id = numeric(),
  plot_name = character(),
  accession_name = character(),
  trait_name = character(),
  value = numeric()
)

for ( observation in observations ) {
  data <- rbind(data, tibble(
    plot_id = as.numeric(observation$observationUnitDbId),
    plot_name = observation$observationUnitName,
    accession_name = observation$germplasmName,
    trait_name = observation$observationVariableName,
    value = as.numeric(observation$value)
  ))
}

# data:
# A tibble: 1,759 × 5
   plot_id plot_name                               accession_name trait_name                                                            value
     <dbl> <chr>                                   <chr>          <chr>                                                                 <dbl>
 1 1039253 YldQtl-Val_2014_ClayCenter_CT213_2127   CT213          Bacterial leaf streak severity - 0-9 percentage scale|CO_321:0501004    5  
 2 1039253 YldQtl-Val_2014_ClayCenter_CT213_2127   CT213          Grain yield - kg/ha|CO_321:0001218                                   3410  
 3 1039253 YldQtl-Val_2014_ClayCenter_CT213_2127   CT213          Plant height - cm|CO_321:0001301                                       82  
 4 1039253 YldQtl-Val_2014_ClayCenter_CT213_2127   CT213          Grain protein content -  %|CO_321:0001205                              15.2
 5 1039254 YldQtl-Val_2014_ClayCenter_NE13593_2297 NE13593        Bacterial leaf streak severity - 0-9 percentage scale|CO_321:0501004    2  
 6 1039254 YldQtl-Val_2014_ClayCenter_NE13593_2297 NE13593        Grain yield - kg/ha|CO_321:0001218                                   3416  
 7 1039254 YldQtl-Val_2014_ClayCenter_NE13593_2297 NE13593        Plant height - cm|CO_321:0001301                                       90  
 8 1039254 YldQtl-Val_2014_ClayCenter_NE13593_2297 NE13593        Grain protein content -  %|CO_321:0001205                              16.4
 9 1039255 YldQtl-Val_2014_ClayCenter_HW_98_2360   HW_98          Bacterial leaf streak severity - 0-9 percentage scale|CO_321:0501004    2  
10 1039255 YldQtl-Val_2014_ClayCenter_HW_98_2360   HW_98          Grain yield - kg/ha|CO_321:0001218                                   2993  
# ℹ 1,749 more rows
# ℹ Use `print(n = ...)` to see more rows
