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
ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = "inst/settings/CohortsToCreate.csv",
                                                 baseUrl = Sys.getenv("ohdsiBaseUrl"),
                                                 insertTableSql = TRUE,
                                                 insertCohortCreationR = TRUE,
                                                 generateStats = TRUE,
                                                 packageName = "Covid19DrugRepurposing")


# Generate all estimation questions ---------------------------------------
cmExposureGroups <- read.csv("extras/CmExposureGroups.csv")
sccsExposureGroups <- read.csv("extras/SccsExposureGroups.csv")
ncsPerExposureGroup <- read.csv("extras/NegativeControlsPerExposureGroup.csv")
outcomesOfInterest <- read.csv("extras/OutcomesOfInterest.csv")

# CohortMethod negative controls
cmNegativeControls <- merge(cmExposureGroups, ncsPerExposureGroup)
write.csv(cmNegativeControls, "inst/settings/NegativeControls.csv")

# SCCS negative controls
sccsNegativeControls <- merge(sccsExposureGroups, ncsPerExposureGroup)
write.csv(sccsNegativeControls, "inst/settings/sccsNegativeControls.csv")

# SCCS research questions of interest
tosOfInterest <- merge(sccsExposureGroups, outcomesOfInterest)
write.csv(tosOfInterest, "inst/settings/tosOfInterest.csv")


# Create analysis details -------------------------------------------------
source("extras/CreateAnalysisSettings.R")
createSccsAnalysesDetails("inst/settings/sccsAnalysisSettings.json")

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("Covid19DrugRepurposing")
