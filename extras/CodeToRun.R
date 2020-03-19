library(Covid19DrugRepurposing)

options(fftempdir = "s:/FFtemp")
connectionDetails <- createConnectionDetails(dbms = "pdw",
                                             server = Sys.getenv("PDW_SERVER"),
                                             port = Sys.getenv("PDW_PORT"))
studyFolder <- "s:/Covid19DrugRepurposing"
maxCores <- parallel::detectCores()

# CCAE settings
databaseId <- "CCAE"
cdmDatabaseSchema <- "CDM_IBM_CCAE_V1103.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_covid19_ccae"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

# MDCR settings
databaseId <- "MDCR"
cdmDatabaseSchema <- "CDM_IBM_MDCR_V1104.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_covid19_mdcr"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

# MDCD settings
databaseId <- "MDCD"
cdmDatabaseSchema <- "CDM_IBM_MDCD_V1105.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_covid19_mdcd"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

# JMDC settings
databaseId <- "JMDC"
cdmDatabaseSchema <- "CDM_JMDC_V1106.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_covid19_jmdc"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

# Optum settings
databaseId <- "Optum"
cdmDatabaseSchema <- "CDM_OPTUM_EXTENDED_DOD_V1107.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_covid19_optum"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        createCohorts = FALSE,
        runSccs = TRUE,
        runSccsDiagnostics = TRUE,
        maxCores = maxCores)
