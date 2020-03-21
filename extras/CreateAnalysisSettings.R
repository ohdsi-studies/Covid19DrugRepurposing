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

createSccsAnalysesDetails <- function(fileName) {

  getDbSccsDataArgs1 <- SelfControlledCaseSeries::createGetDbSccsDataArgs(maxCasesPerOutcome = 100000,
                                                                          exposureIds = c())
  
  covarExposureOfInt1 <- SelfControlledCaseSeries::createCovariateSettings(label = "Exposure of interest",
                                                                           includeCovariateIds = "exposureId",
                                                                           start = 1,
                                                                           end = 0,
                                                                           addExposedDaysToEnd = TRUE)
  
  # createSccsEraDataArgs1 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(naivePeriod = 365,
  #                                                                                 firstOutcomeOnly = FALSE,
  #                                                                                 covariateSettings = covarExposureOfInt1)
  # 
  # fitSccsModelArgs1 <- SelfControlledCaseSeries::createFitSccsModelArgs()
  # 
  # sccsAnalysis1 <- SelfControlledCaseSeries::createSccsAnalysis(analysisId = 1,
  #                                                               description = "Simple SCCS",
  #                                                               getDbSccsDataArgs = getDbSccsDataArgs1,
  #                                                               createSccsEraDataArgs = createSccsEraDataArgs1,
  #                                                               fitSccsModelArgs = fitSccsModelArgs1)
  
  # covarAllDrugs = SelfControlledCaseSeries::createCovariateSettings(label = "All other exposures",
  #                                                                   excludeCovariateIds = "exposureId",
  #                                                                   stratifyById = TRUE,
  #                                                                   start = 1,
  #                                                                   end = 0,
  #                                                                   addExposedDaysToEnd = TRUE,
  #                                                                   allowRegularization = TRUE)
  # 
  # createSccsEraDataArgs6 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(naivePeriod = 365,
  #                                                                                 firstOutcomeOnly = TRUE,
  #                                                                                 covariateSettings = list(covarExposureOfInt1,
  #                                                                                                          covarAllDrugs))
  # prior = Cyclops::createPrior("laplace", useCrossValidation = TRUE)
  # control = Cyclops::createControl(cvType = "auto",
  #                                  selectorType = "byPid",
  #                                  startingVariance = 0.01,
  #                                  noiseLevel = "quiet",
  #                                  fold = 10,
  #                                  cvRepetitions = 1,
  #                                  tolerance = 2e-07)
  # fitSccsModelArgs2 <- SelfControlledCaseSeries::createFitSccsModelArgs(prior = prior, control = control)
  # 
  # sccsAnalysis1 <- SelfControlledCaseSeries::createSccsAnalysis(analysisId = 1,
  #                                                               description = "Using all other exposures",
  #                                                               getDbSccsDataArgs = getDbSccsDataArgs1,
  #                                                               createSccsEraDataArgs = createSccsEraDataArgs6,
  #                                                               fitSccsModelArgs = fitSccsModelArgs2)
  ageSettings <- SelfControlledCaseSeries::createAgeSettings(includeAge = TRUE)
  seasonalitySettings <- SelfControlledCaseSeries::createSeasonalitySettings(includeSeasonality = TRUE)
  createSccsEraDataArgs1 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(naivePeriod = 365,
                                                                                  firstOutcomeOnly = TRUE,
                                                                                  covariateSettings = covarExposureOfInt1,
                                                                                  ageSettings = ageSettings,
                                                                                  seasonalitySettings = seasonalitySettings)
  
  fitSccsModelArgs1 <- SelfControlledCaseSeries::createFitSccsModelArgs()
  
  sccsAnalysis1 <- SelfControlledCaseSeries::createSccsAnalysis(analysisId = 1,
                                                                description = "Using age and season",
                                                                getDbSccsDataArgs = getDbSccsDataArgs1,
                                                                createSccsEraDataArgs = createSccsEraDataArgs1,
                                                                fitSccsModelArgs = fitSccsModelArgs1)
  
  sccsAnalysisList <- list(sccsAnalysis1)
  SelfControlledCaseSeries::saveSccsAnalysisList(sccsAnalysisList, fileName)
}