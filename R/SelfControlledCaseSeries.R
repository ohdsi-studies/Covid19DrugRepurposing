# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of Covid19DrugRepurposing
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Execute the Self-Controlled Case Series analyses
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param outcomeDatabaseSchema Schema name where the outcome cohorts are stored. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param outcomeTable         The name of the table in the outcome database schema that holds the outcome cohorts,
#' @param exposureDatabaseSchema Schema name where the exposure cohorts are stored. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param exposureTable         The name of the table in the exposure database schema that holds the exposure cohorts,
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param maxCores             How many parallel cores should be used? If more cores are made available
#'                             this can speed up the analyses.
#'
#' @export
runSelfControlledCaseSeries <- function(connectionDetails,
                                        cdmDatabaseSchema,
                                        oracleTempSchema = NULL,
                                        outcomeDatabaseSchema = cdmDatabaseSchema,
                                        outcomeTable = "cohort",
                                        exposureDatabaseSchema = cdmDatabaseSchema,
                                        exposureTable = "drug_era",
                                        outputFolder,
                                        maxCores) {
    start <- Sys.time()
    sccsFolder <- file.path(outputFolder, "selfControlledCaseSeries")
    if (!file.exists(sccsFolder))
        dir.create(sccsFolder)

    sccsSummaryFile <- file.path(outputFolder, "sccsSummary.rds")
    if (!file.exists(sccsSummaryFile)) {
        eoList <- createTos(outputFolder)
        sccsAnalysisListFile <- system.file("settings", "sccsAnalysisSettings.txt", package = "Covid19DrugRepurposing")
        sccsAnalysisList <- SelfControlledCaseSeries::loadSccsAnalysisList(sccsAnalysisListFile)
        sccsResult <- SelfControlledCaseSeries::runSccsAnalyses(connectionDetails = connectionDetails,
                                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                                oracleTempSchema = oracleTempSchema,
                                                                exposureDatabaseSchema = exposureDatabaseSchema,
                                                                exposureTable = exposureTable,
                                                                outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                                outcomeTable = outcomeTable,
                                                                sccsAnalysisList = sccsAnalysisList,
                                                                exposureOutcomeList = eoList,
                                                                outputFolder = sccsFolder,
                                                                combineDataFetchAcrossOutcomes = TRUE,
                                                                compressSccsEraDataFiles = TRUE,
                                                                getDbSccsDataThreads = min(3, maxCores),
                                                                createSccsEraDataThreads = min(5, maxCores),
                                                                fitSccsModelThreads = min(max(1, floor(maxCores/8)), 4),
                                                                cvThreads =  min(10, maxCores))

        sccsSummary <- SelfControlledCaseSeries::summarizeSccsAnalyses(sccsResult, sccsFolder)
        saveRDS(sccsSummary, sccsSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed SCCS analyses in", signif(delta, 3), attr(delta, "units")))
}

createTos <- function(outputFolder) {
    pathToCsv <- system.file("settings", "TosOfInterest.csv", package = "Covid19DrugRepurposing")
    tosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE)
    
    pathToCsv <- system.file("settings", "sccsNegativeControls.csv", package = "Covid19DrugRepurposing")
    ncs <- read.csv(pathToCsv, stringsAsFactors = FALSE)
    allControls <- ncs
    
    tos <- unique(rbind(tosOfInterest[, c("exposureId", "outcomeId")],
                        allControls[, c("exposureId", "outcomeId")]))
    createTo <- function(i) {
        exposureOutcome <- SelfControlledCaseSeries::createExposureOutcome(exposureId = tos$exposureId[i],
                                                                           outcomeId = tos$outcomeId[i])
        return(exposureOutcome)
    }
    tosList <- lapply(1:nrow(tos), createTo)
    return(tosList)
}