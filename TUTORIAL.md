# T3/Wheat Tutorial

This Tutorial uses the `BrAPI` R package to query the T3/Wheat Breedbase database for trials, phenotype data, and genotype data.  The same functions should work the same for any BrAPI-compliant database (using v2 of the BrAPI specification), _with the exception of the genotype-data related queries, which use breedbase-specific query functions_.

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
programs
 [1] "Agharkar Research Institute Wheat Program"
 [2] "Agricultural Biotechnology Research Institute, Faisalabad"
 [3] "Agriculture and Agri-Food Canada"
 [4] "Agriculture and Agri-Food Canada Alberta"
 [5] "Agriculture and Agri-Food Canada Manitoba"
 [6] "Agriculture and Agri-Food Canada Saskatchewan"
 [7] "AgriPro-Syngenta"
 [8] "Allele Based Breeding Cooperative"
 [9] "Cereal Research Institute Non-Profit Ltd."
[10] "CIMMYT"
```

## Trials

If you want to give the user a list of trials to choose from, you can get a list of trial names and ids filtered by a selected breeding program:

```R
selected_breeding_program <- "University of Nebraska"
resp <- wheat$get("/studies", query=list(programName=selected_breeding_program), page="all")
trials <- tibble(
	id = sapply(resp$combined_data, \(x) { as.numeric(x$studyDbId) }),
	name = sapply(resp$combined_data, \(x) { x$studyName })
)
trials
# A tibble: 42 × 2
      id name
   <dbl> <chr>
 1  5710 CSR-Val_2015_Mead
 2  7438 NEBDUP_2010_Alliance
 3  6598 NEBDUP_2010_ClayCenter
 4  6802 NEBDUP_2010_Lincoln
```

## Trial Metadata

Once you have the trials you are interested in, you can get the trial metadata (such as trial location, design type, planting/harvest dates, year, etc):

```R
selected_trials <- c("YldQtl-Val_2014_ClayCenter", "YldQtl-Val_2014_Lincoln", "YldQtl-Val_2014_Mead", "YldQtl-Val_2014_Sidney")
resp <- wheat$search("/studies", body=list(studyNames=selected_trials))
trial_metadata <- tibble(
    id = sapply(resp$combined_data, \(x) { as.numeric(x$studyDbId) }),
    name = sapply(resp$combined_data, \(x) { x$studyName }),
    location = sapply(resp$combined_data, \(x) { x$locationName }),
    year = sapply(resp$combined_data, \(x) { as.numeric(x$seasons[[1]]) }),
    planting_date = sapply(resp$combined_data, \(x) { x$startDate }),
    harvest_date = sapply(resp$combined_data, \(x) { x$endDate }),
    design = sapply(resp$combined_data, \(x) { x$experimentalDesign$PUI })
)
trial_metadata
# A tibble: 4 × 7
     id name                    location year  planting_date harvest_date design
  <dbl> <chr>                   <chr>    <dbl> <chr>         <list>       <chr>
1  6104 YldQtl-Val_2014_ClayCe… Clay Ce… 2014  2013-09-23T0… <NULL>       CRD
2  5988 YldQtl-Val_2014_Lincoln Lincoln… 2014  2013-10-01T0… <NULL>       CRD
3  5656 YldQtl-Val_2014_Mead    Ithaca,… 2014  2013-09-25T0… <NULL>       CRD
4  5839 YldQtl-Val_2014_Sidney  Sidney,… 2014  2013-09-18T0… <NULL>       CRD
```

## Trial Layout

The plot layout for a trial is defined by getting the relative plot positions.  Each plot will have a row and column position if they were assigned when the trial was added to the database.  To get the layout, you'll need to get all of the plots (observation units) from the trial and extract the row and column information:

```R
selected_trial_id <- "6104"
resp <- wheat$get("/observationunits", query=list(studyDbId=selected_trial_id), page="all", pageSize=100)
trial_layout <- tibble(
    trial_id = sapply(resp$combined_data, \(x) { as.numeric(x$studyDbId) }),
    trial_name = sapply(resp$combined_data, \(x) { x$studyName }),
    plot_id = sapply(resp$combined_data, \(x) { as.numeric(x$observationUnitDbId) }),
    plot_name = sapply(resp$combined_data, \(x) { x$observationUnitName }),
    row = sapply(resp$combined_data, \(x) { as.numeric(x$observationUnitPosition$positionCoordinateY) }),
    col = sapply(resp$combined_data, \(x) { as.numeric(x$observationUnitPosition$positionCoordinateX) }),
    accession_id = sapply(resp$combined_data, \(x) { as.numeric(x$germplasmDbId) }),
    accession_name = sapply(resp$combined_data, \(x) { x$germplasmName }),
)
trial_layout
# A tibble: 440 × 8
   trial_id trial_name plot_id plot_name   row   col accession_id accession_name
      <dbl> <chr>        <dbl> <chr>     <dbl> <dbl>        <dbl> <chr>
 1     6104 YldQtl-Va… 1039408 YldQtl-V…    10    40       222467 11_26
 2     6104 YldQtl-Va… 1039387 YldQtl-V…    17    48       222467 11_26
 3     6104 YldQtl-Va… 1039591 YldQtl-V…    10    41       221091 11_73
 4     6104 YldQtl-Va… 1039559 YldQtl-V…    17    49       221091 11_73
 5     6104 YldQtl-Va… 1039549 YldQtl-V…    20    34       219436 13_13
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
  plot_id = sapply(observations, \(x) { as.numeric(x$observationUnitDbId) }),
  plot_name = sapply(observations, \(x) { x$observationUnitName }),
  accession_name = sapply(observations, \(x) { x$germplasmName }),
  trait_name = sapply(observations, \(x) { x$observationVariableName }),
  value = sapply(observations, \(x) { as.numeric(x$value) })
)
data
# A tibble: 1,759 × 5
   plot_id plot_name                            accession_name trait_name  value
     <dbl> <chr>                                <chr>          <chr>       <dbl>
 1 1039408 YldQtl-Val_2014_ClayCenter_11_26_20… 11_26          Bacterial…    3
 2 1039408 YldQtl-Val_2014_ClayCenter_11_26_20… 11_26          Grain yie… 3773
 3 1039408 YldQtl-Val_2014_ClayCenter_11_26_20… 11_26          Plant hei…   84
 4 1039408 YldQtl-Val_2014_ClayCenter_11_26_20… 11_26          Grain pro…   15.0
 5 1039387 YldQtl-Val_2014_ClayCenter_11_26_23… 11_26          Bacterial…    3
 6 1039387 YldQtl-Val_2014_ClayCenter_11_26_23… 11_26          Grain yie… 2360
```

## Genotype Data


> [!WARNING]  
> The following examples for fetching genotype data use the breedbase-specific functions for finding appropriate genotype projects and downloading archived VCF files.  These functions only work with breedbase databases and do not use functions defined in the BrAPI specification.

### Finding an appropriate Genotyping Project

Since there is generally not a 1:1 association between a phenotyping field trial and a genotyping project, some work has to be done to find which genotyping project on the database best represents the accessions in the trial.  To do this, you can use the breedbase-specific function `filter_geno_projects()` which will return a list of the genotyping projects which have the highest number of accessions sampled from the list of accessions you provide.

```R
# Set your list of accessions that you're interested in (by id)
my_accessions <- c(234712, 1544778, 1478255, 1550494, 1544454)

# Find the best project for these accessions
resp <- wheat$filter_geno_projects(accessions = my_accessions)
Top genotyping projects:
1. UWM_2023_3K [id=11009] (2/5 accessions)
2. KSU_2023_Allegro [id=10655] (2/5 accessions)
3. UCD_2020_Allegro_V2 [id=10727] (1/5 accessions)
4. KSU_2023_Allegro_V2 [id=10683] (1/5 accessions)
5. UCD_2020_Allegro [id=10654] (1/5 accessions)
```

### Downloading VCF Data
Once you know which genotyping project best represents your set of accessions, the most efficient way to download the genotype data is to download the archived VCF file for that project.  This will return the original VCF file that was used to upload the genotype data to the database.  _NOTE: this VCF file will include all of the accessions sampled in the project.  If you want to subset the samples to include only your set of accessions, you'll need to do that after you download the file._

```R
# Download a genotyping project to your computer
wheat$vcf_archived("~/Desktop/data.vcf", genotyping_project_id=11009)
```