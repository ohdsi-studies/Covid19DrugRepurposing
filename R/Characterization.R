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

createCharacterization <- function(connectionDetails,
                                   cdmDatabaseSchema,
                                   cohortDatabaseSchema = cdmDatabaseSchema,
                                   cohortTable,
                                   oracleTempSchema = cohortDatabaseSchema,
                                   outputFolder,
                                   exposureIds = NULL) {
  covariatesFolder <- file.path(outputFolder, "covariates")
  if (!file.exists(covariatesFolder)) {
    dir.create(covariatesFolder, recursive = TRUE)
  }
  
  pathToCsv <- system.file("settings", "TosOfInterest.csv", package = "Covid19DrugRepurposing")
  tosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE)
  if (!is.null(exposureIds)) {
    ParallelLogger::logInfo("Limiting to exposure ID(s) ", paste(exposureIds, sep = ", "))
    tosOfInterest <- tosOfInterest[tosOfInterest$exposureId %in% exposureIds, ]
  }
  
  # Determine washout period based on first analysis:
  sccsAnalysisListFile <- system.file("settings", "sccsAnalysisList.json", package = "Covid19DrugRepurposing")
  sccsAnalysisList <- SelfControlledCaseSeries::loadSccsAnalysisList(sccsAnalysisListFile)
  washoutDays <- sccsAnalysisList[[1]]$createSccsEraDataArgs$naivePeriod
  
  covariateSettings <- FeatureExtraction::createDefaultCovariateSettings()
  
  connection <- DatabaseConnector::connect(connectionDetails)  
  on.exit(DatabaseConnector::disconnect(connection))
  
  for (i in 1:nrow(tosOfInterest)) {
    eoCovariatesFolder <- file.path(covariatesFolder, sprintf("covariates_e%s_o%s", tosOfInterest$exposureId[i], tosOfInterest$outcomeId[i]))
    if (!file.exists(eoCovariatesFolder)) {  
      ParallelLogger::logInfo(sprintf("Creating characteristics for exposure %s and outcome %s", tosOfInterest$exposureId[i], tosOfInterest$outcomeId[i]))
      # Create at-risk cohorts
      ParallelLogger::logInfo("Creating cohort to characterize")
      sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "CreateAtRiskCohorts.sql",
                                               packageName = "Covid19DrugRepurposing",
                                               dbms = connectionDetails$dbms,
                                               oracleTempSchema = oracleTempSchema,
                                               cdm_database_schema = cdmDatabaseSchema,
                                               cohort_database_schema = cohortDatabaseSchema,
                                               cohort_table = cohortTable,
                                               exposure_id = tosOfInterest$exposureId[i],
                                               outcome_id = tosOfInterest$outcomeId[i],
                                               washout_days = washoutDays)
      DatabaseConnector::executeSql(connection, sql)
      
      # Extract features per cohort:
      covariateData <- FeatureExtraction::getDbCovariateData(connection = connection,
                                                             oracleTempSchema = oracleTempSchema,
                                                             cdmDatabaseSchema = cdmDatabaseSchema,
                                                             cohortTable = "#at_risk_cohort",
                                                             cohortTableIsTemp = TRUE,
                                                             covariateSettings = covariateSettings,
                                                             aggregated = TRUE)
      FeatureExtraction::saveCovariateData(covariateData, eoCovariatesFolder)
    }
  }
  sql <- "TRUNCATE TABLE #at_risk_cohort; DROP TABLE #at_risk_cohort;"
  DatabaseConnector::renderTranslateExecuteSql(connection, sql, oracleTempSchema = oracleTempSchema, progressBar = FALSE, reportOverallTime = FALSE)
  
  
  
  
}