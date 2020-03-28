# Copyright 2019 Observational Health Data Sciences and Informatics
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

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("Covid19DrugRepurposing")
OhdsiRTools::updateCopyrightYearFolder()
devtools::spell_check()

# Create manual -----------------------------------------------------------
unlink("extras/Covid19DrugRepurposing.pdf")
shell("R CMD Rd2pdf ./ --output=extras/Covid19DrugRepurposing.pdf")


# Insert cohort definitions from ATLAS into package -----------------------
ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = "inst/settings/CohortsToCreateJnJAtlas.csv",
                                                 baseUrl = Sys.getenv("baseUrl"),
                                                 insertTableSql = TRUE,
                                                 insertCohortCreationR = TRUE,
                                                 generateStats = FALSE,
                                                 packageName = "Covid19DrugRepurposing")

ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = "inst/settings/CohortsToCreateCovidAtlas.csv",
                                                 baseUrl = Sys.getenv("ohdsiCovidBaseUrl"),
                                                 insertTableSql = TRUE,
                                                 insertCohortCreationR = TRUE,
                                                 generateStats = FALSE,
                                                 packageName = "Covid19DrugRepurposing")

# Merge cohorts to create files
cohortsToCreate1 <- read.csv("inst/settings/CohortsToCreateJnJAtlas.csv")
cohortsToCreate2 <- read.csv("inst/settings/CohortsToCreateCovidAtlas.csv")
cohortsToCreate <- rbind(cohortsToCreate1, cohortsToCreate2)
write.csv(cohortsToCreate, "inst/settings/CohortsToCreate.csv", row.names = FALSE)

# Generate all estimation questions ---------------------------------------
sccsExposureGroups <- read.csv("extras/SccsExposureGroups.csv")
ncsPerExposureGroup <- read.csv("extras/NegativeControlsPerExposureGroup.csv")
outcomesOfInterest <- read.csv("extras/OutcomesOfInterest.csv")

# SCCS negative controls
sccsNegativeControls <- merge(sccsExposureGroups, ncsPerExposureGroup)
write.csv(sccsNegativeControls, "inst/settings/sccsNegativeControls.csv", row.names = FALSE)

# SCCS research questions of interest
tosOfInterest <- merge(sccsExposureGroups, outcomesOfInterest)
write.csv(tosOfInterest, "inst/settings/tosOfInterest.csv", row.names = FALSE)


# Create analysis details -------------------------------------------------
source("extras/CreateAnalysisSettings.R")
createSccsAnalysesDetails("inst/settings/sccsAnalysisSettings.json")

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("Covid19DrugRepurposing")
