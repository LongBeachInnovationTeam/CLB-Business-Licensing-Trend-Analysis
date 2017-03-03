# City of Long Beach Business Licensing Trend Analysis

## About

> Are there any seasonality patterns in business licensing activity? For example, the licenses in the latter half of the year generally take longer because there is a lot of construction going on. What is the overall trend of licensing activity? This analysis attempts to find out!

## Project Organization

    ├── LICENSE
    ├── README.md          <- The top-level README for developers using this project.
    ├── R                  <- Provides R functions representing commonly used analyses.
    ├── data
    │   ├── external       <- Data from third party sources.
    │   ├── interim        <- Intermediate data that has been transformed.
    │   ├── processed      <- The final, canonical data sets for modeling.
    │   └── raw            <- The original, immutable data dump.
    │
    ├── doc                <- Contains any useful documentation, data dictionaries, screenshots, notes, etc.
    ├── figs               <- Contains generated figures.
    └── src                <- Source code or notebooks for use in this project.
    
## Required Dependencies

- [R](https://www.r-project.org/)
- [tidyverse](http://tidyverse.org/): a collection of R packages that makes data wrangling, munging, and analysis easier.
- [prophet](https://github.com/facebookincubator/prophet): a procedure for forecasting time series data. It is based on an additive model where non-linear trends are fit with yearly and weekly seasonality, plus holidays. It works best with daily periodicity data with at least one year of historical data. Prophet is robust to missing data, shifts in the trend, and large outliers.
    
## Getting Started

- Clone this repo to your computer.
- Install above dependencies into your R development enviornment, if you haven't already.
- Run `mkdir data/raw/` to create a directory for our source datasets.
- Import the latest business licensing datasets as detailed in the [source datasets section](#source-datasets) into `/data/raw/`.
- Run `mkdir data/interim/` to store intermediate datasets for consumption by other code, notebooks, or analysis tools in your stack.
- Open the [R Notebook](http://rmarkdown.rstudio.com/r_notebooks.html) from `src/analysis.Rmd` in [RStudio](https://www.rstudio.com/) to run the analysis.

## Source Datasets

Business licensing data is provided by the City of Long Beach's Financial Management department. We have an internal postgresql database on virtual server `clbisandev02` that serves as the target destination for ETLs that transfers data from the city's Hansen/LMR system every morning.

Export the following CSV's from the `hansen_staging` postgres schema on `clbisandev02` into `/data/raw`:

| Expected file  	        | Source table   	  |  Description 	                                                                                                          |
|---	                    |---	              |---	                                                                                                                    |
| business_licenses.csv   | business_license  | Primary source of record containing information on all of the business licenses issued and administered by the City.    |
| milestones.csv   	      | milestone         | A “log” recording change of status for each business license or application by date/time and inspector.                 |
| permits.csv   	        | permit            | Fee descriptions, fee amounts paid or due for each business license. Includes business improvement district (BID) fees. |


