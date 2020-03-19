library(Covid19DrugRepurposing)

options(fftempdir = "s:/FFtemp")
connectionDetails <- createConnectionDetails(dbms = "pdw",
                                             server = Sys.getenv("PDW_SERVER"),
                                             port = Sys.getenv("PDW_PORT"))
studyFolder <- "s:/PreClinToRwe"
maxCores <- parallel::detectCores()

# CCAE settings
databaseId <- "CCAE"
cdmDatabaseSchema <- "CDM_IBM_CCAE_V1061.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_preclinTorwe_ccae"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

# MDCR settings
databaseId <- "MDCR"
cdmDatabaseSchema <- "CDM_IBM_MDCR_V1062.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_preclinTorwe_mdcr"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

# MDCD settings
databaseId <- "MDCD"
cdmDatabaseSchema <- "CDM_IBM_MDCD_V1023.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_preclinTorwe_mdcd"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

# Optum settings
databaseId <- "Optum"
cdmDatabaseSchema <- "CDM_OPTUM_EXTENDED_SES_V1065.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_preclinTorwe_optum"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, databaseId)

# JMDC settings
databaseId <- "JMDC"
cdmDatabaseSchema <- "CDM_JMDC_V1063.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_preclinTorwe_jmdc"
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
        runDiagnostics = TRUE,
        negativeControlsOnly = TRUE,
        maxCores = maxCores)
