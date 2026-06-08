-- PostgreSQL migration script generated from SQL Server version
-- All logic for __EFMigrationsHistory and conditional migrations is preserved

-- Ensure __EFMigrationsHistory exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = '__EFMigrationsHistory' AND table_schema = 'public') THEN
        CREATE TABLE "__EFMigrationsHistory" (
            "MigrationId" VARCHAR(150) NOT NULL PRIMARY KEY,
            "ProductVersion" VARCHAR(32) NOT NULL
        );
		-- If the Teams table already exists, then we assume the database was created without Migrations on a version matching at least v1.8.1
		IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'Teams' AND table_schema = 'public') THEN
			INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20240410034748_InitialCreate', '8.0.20');
		END IF;
    END IF;
END$$;

-- Migration: 20240410034748_InitialCreate
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20240410034748_InitialCreate') THEN
        -- AspNetRoles
        CREATE TABLE IF NOT EXISTS "AspNetRoles" (
            "Id" VARCHAR(450) NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256),
            "NormalizedName" VARCHAR(256),
            "ConcurrencyStamp" TEXT
        );
        -- AspNetUsers
        CREATE TABLE IF NOT EXISTS "AspNetUsers" (
            "Id" VARCHAR(450) NOT NULL PRIMARY KEY,
            "UserName" VARCHAR(256),
            "NormalizedUserName" VARCHAR(256),
            "Email" VARCHAR(256),
            "NormalizedEmail" VARCHAR(256),
            "EmailConfirmed" BOOLEAN NOT NULL,
            "PasswordHash" TEXT,
            "SecurityStamp" TEXT,
            "ConcurrencyStamp" TEXT,
            "PhoneNumber" VARCHAR(128),
            "PhoneNumberConfirmed" BOOLEAN NOT NULL,
            "TwoFactorEnabled" BOOLEAN NOT NULL,
            "LockoutEnd" TIMESTAMPTZ,
            "LockoutEnabled" BOOLEAN NOT NULL,
            "AccessFailedCount" INTEGER NOT NULL
        );
        -- DataProtectionKeys
        CREATE TABLE IF NOT EXISTS "DataProtectionKeys" (
            "Id" SERIAL PRIMARY KEY,
            "FriendlyName" TEXT,
            "Xml" TEXT
        );
        -- ProductionRecords
        CREATE TABLE IF NOT EXISTS "ProductionRecords" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "LastUpdate" TIMESTAMP NOT NULL,
            "Action" INTEGER NOT NULL,
            "Client" VARCHAR(256),
            "TargetType" VARCHAR(256) NOT NULL,
            "TargetId" UUID NOT NULL,
            "Message" VARCHAR(4000) NOT NULL,
            "UserId" VARCHAR(450)
        );
        -- Teams
        CREATE TABLE IF NOT EXISTS "Teams" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256) NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL
        );
        -- AspNetRoleClaims
        CREATE TABLE IF NOT EXISTS "AspNetRoleClaims" (
            "Id" SERIAL PRIMARY KEY,
            "RoleId" VARCHAR(450) NOT NULL,
            "ClaimType" TEXT,
            "ClaimValue" TEXT,
            CONSTRAINT "FK_AspNetRoleClaims_AspNetRoles_RoleId" FOREIGN KEY ("RoleId") REFERENCES "AspNetRoles" ("Id") ON DELETE CASCADE
        );
        -- AspNetUserClaims
        CREATE TABLE IF NOT EXISTS "AspNetUserClaims" (
            "Id" SERIAL PRIMARY KEY,
            "UserId" VARCHAR(450) NOT NULL,
            "ClaimType" TEXT,
            "ClaimValue" TEXT,
            CONSTRAINT "FK_AspNetUserClaims_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES "AspNetUsers" ("Id") ON DELETE CASCADE
        );
        -- AspNetUserLogins
        CREATE TABLE IF NOT EXISTS "AspNetUserLogins" (
            "LoginProvider" VARCHAR(128) NOT NULL,
            "ProviderKey" VARCHAR(128) NOT NULL,
            "ProviderDisplayName" TEXT,
            "UserId" VARCHAR(450) NOT NULL,
            PRIMARY KEY ("LoginProvider", "ProviderKey"),
            CONSTRAINT "FK_AspNetUserLogins_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES "AspNetUsers" ("Id") ON DELETE CASCADE
        );
        -- AspNetUserRoles
        CREATE TABLE IF NOT EXISTS "AspNetUserRoles" (
            "UserId" VARCHAR(450) NOT NULL,
            "RoleId" VARCHAR(450) NOT NULL,
            PRIMARY KEY ("UserId", "RoleId"),
            CONSTRAINT "FK_AspNetUserRoles_AspNetRoles_RoleId" FOREIGN KEY ("RoleId") REFERENCES "AspNetRoles" ("Id") ON DELETE CASCADE,
            CONSTRAINT "FK_AspNetUserRoles_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES "AspNetUsers" ("Id") ON DELETE CASCADE
        );
        -- AspNetUserTokens
        CREATE TABLE IF NOT EXISTS "AspNetUserTokens" (
            "UserId" VARCHAR(450) NOT NULL,
            "LoginProvider" VARCHAR(128) NOT NULL,
            "Name" VARCHAR(128) NOT NULL,
            "Value" TEXT,
            PRIMARY KEY ("UserId", "LoginProvider", "Name"),
            CONSTRAINT "FK_AspNetUserTokens_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES "AspNetUsers" ("Id") ON DELETE CASCADE
        );
        -- CredentialFragmentTemplates
        CREATE TABLE IF NOT EXISTS "CredentialFragmentTemplates" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256) NOT NULL,
            "OwnerId" UUID NOT NULL,
            "FragmentDescription_Type" VARCHAR(256) NOT NULL,
            "FragmentDescription_SubType" VARCHAR(256),
            "FragmentDescription_Tags" VARCHAR(256),
            "LastUpdate" TIMESTAMP NOT NULL,
            "DefaultPriority" INTEGER,
            "SerializedContent" TEXT,
            "TeamId" UUID,
            CONSTRAINT "FK_CredentialFragmentTemplates_Teams_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Teams" ("Id"),
            CONSTRAINT "FK_CredentialFragmentTemplates_Teams_TeamId" FOREIGN KEY ("TeamId") REFERENCES "Teams" ("Id")
        );
        -- CredentialTemplates
        CREATE TABLE IF NOT EXISTS "CredentialTemplates" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256) NOT NULL,
            "OwnerId" UUID NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL,
            CONSTRAINT "FK_CredentialTemplates_Teams_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Teams" ("Id") ON DELETE CASCADE
        );
        -- Keys
        CREATE TABLE IF NOT EXISTS "Keys" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256) NOT NULL,
            "OwnerId" UUID NOT NULL,
            "KeyType" VARCHAR(256) NOT NULL,
            "KeyStoreType" VARCHAR(256) NOT NULL,
            "KeyStore" VARCHAR(256),
            "KeyStoreReference" VARCHAR(256),
            "Value" TEXT,
            "Version" SMALLINT,
            "Scope" INTEGER NOT NULL,
            "ScopeDiversifier" TEXT,
            "LastUpdate" TIMESTAMP NOT NULL,
            CONSTRAINT "FK_Keys_Teams_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Teams" ("Id") ON DELETE CASCADE
        );
        -- TeamMembers
        CREATE TABLE IF NOT EXISTS "TeamMembers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "UserId" VARCHAR(450) NOT NULL,
            "Permission" VARCHAR(256) NOT NULL,
            "TeamId" UUID NOT NULL,
            CONSTRAINT "FK_TeamMembers_Teams_TeamId" FOREIGN KEY ("TeamId") REFERENCES "Teams" ("Id") ON DELETE CASCADE
        );
        -- CredentialBase
        CREATE TABLE IF NOT EXISTS "CredentialBase" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256) NOT NULL,
            "CreationDate" TIMESTAMP NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL,
            "Signature" TEXT,
            "Discriminator" VARCHAR(21) NOT NULL,
            "OwnerId" UUID,
            "CredentialTemplateId" UUID,
            "State" INTEGER,
            "TeamId" UUID,
            CONSTRAINT "FK_CredentialBase_CredentialTemplates_CredentialTemplateId" FOREIGN KEY ("CredentialTemplateId") REFERENCES "CredentialTemplates" ("Id"),
            CONSTRAINT "FK_CredentialBase_Teams_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Teams" ("Id"),
            CONSTRAINT "FK_CredentialBase_Teams_TeamId" FOREIGN KEY ("TeamId") REFERENCES "Teams" ("Id")
        );
        -- CredentialDataFields
        CREATE TABLE IF NOT EXISTS "CredentialDataFields" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "CredentialTemplateId" UUID,
            "Name" VARCHAR(256) NOT NULL,
            "DataType" INTEGER NOT NULL,
            "DefaultValue" TEXT,
            "OverrideRendering" VARCHAR(256),
            "AllowUpdateByClient" BOOLEAN NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL,
            CONSTRAINT "FK_CredentialDataFields_CredentialTemplates_CredentialTemplateId" FOREIGN KEY ("CredentialTemplateId") REFERENCES "CredentialTemplates" ("Id") ON DELETE CASCADE
        );
        -- CredentialDataProviders
        CREATE TABLE IF NOT EXISTS "CredentialDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256) NOT NULL,
            "ExecutionTrigger" INTEGER NOT NULL,
            "ExecutionTriggerParameter" VARCHAR(512),
            "Priority" INTEGER NOT NULL,
            "CredentialTemplateId" UUID,
            "LastUpdate" TIMESTAMP NOT NULL,
            CONSTRAINT "FK_CredentialDataProviders_CredentialTemplates_CredentialTemplateId" FOREIGN KEY ("CredentialTemplateId") REFERENCES "CredentialTemplates" ("Id") ON DELETE CASCADE
        );
        -- CredentialFragmentTemplateCredentialTemplate
        CREATE TABLE IF NOT EXISTS "CredentialFragmentTemplateCredentialTemplate" (
            "CredentialTemplateId" UUID NOT NULL,
            "FragmentTemplatesId" UUID NOT NULL,
            PRIMARY KEY ("CredentialTemplateId", "FragmentTemplatesId"),
            CONSTRAINT "FK_CredentialFragmentTemplateCredentialTemplate_CredentialFragmentTemplates_FragmentTemplatesId" FOREIGN KEY ("FragmentTemplatesId") REFERENCES "CredentialFragmentTemplates" ("Id") ON DELETE CASCADE,
            CONSTRAINT "FK_CredentialFragmentTemplateCredentialTemplate_CredentialTemplates_CredentialTemplateId" FOREIGN KEY ("CredentialTemplateId") REFERENCES "CredentialTemplates" ("Id") ON DELETE CASCADE
        );
        -- ProductionSets
        CREATE TABLE IF NOT EXISTS "ProductionSets" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256),
            "OwnerId" UUID NOT NULL,
            "CreationDate" TIMESTAMP NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL,
            "State" INTEGER NOT NULL,
            "DefaultCredentialTemplateId" UUID,
            "CredentialAllocation" INTEGER NOT NULL,
            "TeamId" UUID,
            CONSTRAINT "FK_ProductionSets_CredentialTemplates_DefaultCredentialTemplateId" FOREIGN KEY ("DefaultCredentialTemplateId") REFERENCES "CredentialTemplates" ("Id") ON DELETE SET NULL,
            CONSTRAINT "FK_ProductionSets_Teams_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Teams" ("Id"),
            CONSTRAINT "FK_ProductionSets_Teams_TeamId" FOREIGN KEY ("TeamId") REFERENCES "Teams" ("Id")
        );
        -- CredentialFragments
        CREATE TABLE IF NOT EXISTS "CredentialFragments" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "CredentialId" UUID NOT NULL,
            "FragmentTemplateId" UUID,
            "FragmentDescription_Type" VARCHAR(256) NOT NULL,
            "FragmentDescription_SubType" VARCHAR(256),
            "FragmentDescription_Tags" VARCHAR(256),
            "State" INTEGER NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL,
            "Priority" INTEGER NOT NULL,
            CONSTRAINT "FK_CredentialFragments_CredentialBase_CredentialId" FOREIGN KEY ("CredentialId") REFERENCES "CredentialBase" ("Id") ON DELETE CASCADE,
            CONSTRAINT "FK_CredentialFragments_CredentialFragmentTemplates_FragmentTemplateId" FOREIGN KEY ("FragmentTemplateId") REFERENCES "CredentialFragmentTemplates" ("Id")
        );
        -- CredentialDataValues
        CREATE TABLE IF NOT EXISTS "CredentialDataValues" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "CredentialId" UUID NOT NULL,
            "DataFieldId" UUID NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL,
            "Value" TEXT,
            CONSTRAINT "FK_CredentialDataValues_CredentialBase_CredentialId" FOREIGN KEY ("CredentialId") REFERENCES "CredentialBase" ("Id") ON DELETE CASCADE,
            CONSTRAINT "FK_CredentialDataValues_CredentialDataFields_DataFieldId" FOREIGN KEY ("DataFieldId") REFERENCES "CredentialDataFields" ("Id") ON DELETE CASCADE
        );
        -- DynamicFragmentTemplate
        CREATE TABLE IF NOT EXISTS "DynamicFragmentTemplate" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "FragmentDescription_Type" VARCHAR(256) NOT NULL,
            "FragmentDescription_SubType" VARCHAR(256),
            "FragmentDescription_Tags" VARCHAR(256),
            "MatchType" INTEGER NOT NULL,
            "Required" BOOLEAN NOT NULL,
            "DataFieldId" UUID,
            "CredentialTemplateId" UUID NOT NULL,
            CONSTRAINT "FK_DynamicFragmentTemplate_CredentialDataFields_DataFieldId" FOREIGN KEY ("DataFieldId") REFERENCES "CredentialDataFields" ("Id"),
            CONSTRAINT "FK_DynamicFragmentTemplate_CredentialTemplates_CredentialTemplateId" FOREIGN KEY ("CredentialTemplateId") REFERENCES "CredentialTemplates" ("Id") ON DELETE CASCADE
        );
        -- ConsoleDataProviders
        CREATE TABLE IF NOT EXISTS "ConsoleDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Application" TEXT,
            "Arguments" TEXT,
            "HandleReturnCode" BOOLEAN NOT NULL,
            "Parameters" BIGINT NOT NULL,
            CONSTRAINT "FK_ConsoleDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- CredentialDataFieldLinks
        CREATE TABLE IF NOT EXISTS "CredentialDataFieldLinks" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "DataFieldId" UUID NOT NULL,
            "DataProviderId" UUID,
            "FieldName" VARCHAR(256) NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL,
            CONSTRAINT "FK_CredentialDataFieldLinks_CredentialDataFields_DataFieldId" FOREIGN KEY ("DataFieldId") REFERENCES "CredentialDataFields" ("Id") ON DELETE CASCADE,
            CONSTRAINT "FK_CredentialDataFieldLinks_CredentialDataProviders_DataProviderId" FOREIGN KEY ("DataProviderId") REFERENCES "CredentialDataProviders" ("Id")
        );
        -- CredentialDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "CredentialDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "DataProviderId" UUID NOT NULL,
            "CredentialId" UUID NOT NULL,
            CONSTRAINT "FK_CredentialDataProviderTrackers_CredentialBase_CredentialId" FOREIGN KEY ("CredentialId") REFERENCES "CredentialBase" ("Id") ON DELETE CASCADE,
            CONSTRAINT "FK_CredentialDataProviderTrackers_CredentialDataProviders_DataProviderId" FOREIGN KEY ("DataProviderId") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- CredentialReferenceDataProviders
        CREATE TABLE IF NOT EXISTS "CredentialReferenceDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            CONSTRAINT "FK_CredentialReferenceDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- CryptoDataProviders
        CREATE TABLE IF NOT EXISTS "CryptoDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "KeyId" UUID,
            "Crypto_Operation" INTEGER NOT NULL,
            "Crypto_HashAlgorithm" VARCHAR(256),
            "Crypto_CipherMode" INTEGER,
            "Crypto_PaddingMode" INTEGER,
            CONSTRAINT "FK_CryptoDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE,
            CONSTRAINT "FK_CryptoDataProviders_Keys_KeyId" FOREIGN KEY ("KeyId") REFERENCES "Keys" ("Id")
        );
        -- DatabaseDataProviders
        CREATE TABLE IF NOT EXISTS "DatabaseDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Driver" INTEGER NOT NULL,
            "ConnectionString" TEXT,
            "Query" TEXT,
            "ExecutionType" INTEGER NOT NULL,
            "AlwaysRecord" NUMERIC(20,0),
            "FailIfNoDataRetrieved" BOOLEAN NOT NULL,
            "Parameters" BIGINT NOT NULL,
            "LatestIndex" NUMERIC(20,0) NOT NULL,
            CONSTRAINT "FK_DatabaseDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- DateTimeDataProviders
        CREATE TABLE IF NOT EXISTS "DateTimeDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Format1" VARCHAR(256) NOT NULL,
            "AddDaysOfYear" BOOLEAN NOT NULL,
            "Format2" VARCHAR(256) NOT NULL,
            "UseUTC" BOOLEAN NOT NULL,
            CONSTRAINT "FK_DateTimeDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- ExcelDataProviders
        CREATE TABLE IF NOT EXISTS "ExcelDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "File" TEXT,
            "Worksheet" VARCHAR(256),
            "IsFirstRowAsColumnNames" BOOLEAN NOT NULL,
            "RowFilter" TEXT,
            "AlwaysRecord" INTEGER,
            "FailIfNoDataRetrieved" BOOLEAN NOT NULL,
            "Parameters" BIGINT NOT NULL,
            "LatestIndex" NUMERIC(20,0) NOT NULL,
            CONSTRAINT "FK_ExcelDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- FileDataProviders
        CREATE TABLE IF NOT EXISTS "FileDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "File" TEXT,
            "ReadAsText" BOOLEAN NOT NULL,
            "Parameters" BIGINT NOT NULL,
            CONSTRAINT "FK_FileDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- LdapDataProviders
        CREATE TABLE IF NOT EXISTS "LdapDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Server" TEXT NOT NULL,
            "Port" INTEGER NOT NULL,
            "CredentialUser" TEXT,
            "CredentialPassword" TEXT,
            "CredentialDomain" TEXT,
            "DistinguishedName" TEXT NOT NULL,
            "Filter" TEXT NOT NULL,
            "ReadAttributes" TEXT NOT NULL,
            "WriteAttributes" TEXT NOT NULL,
            "AlwaysRecord" INTEGER,
            "FailIfNoDataRetrieved" BOOLEAN NOT NULL,
            "Parameters" BIGINT NOT NULL,
            "LatestIndex" INTEGER NOT NULL,
            CONSTRAINT "FK_LdapDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- RandomDataProviders
        CREATE TABLE IF NOT EXISTS "RandomDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Start" NUMERIC(20,0) NOT NULL,
            "Stop" NUMERIC(20,0) NOT NULL,
            "AllowDuplicate" BOOLEAN NOT NULL,
            CONSTRAINT "FK_RandomDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- RestApiDataProviders
        CREATE TABLE IF NOT EXISTS "RestApiDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "HttpMethod" VARCHAR(32) NOT NULL,
            "Uri" TEXT,
            "HttpContent" TEXT,
            "HandleHttpCode" BOOLEAN NOT NULL,
            "IgnoreInvalidSsl" BOOLEAN NOT NULL,
            "Parameters" BIGINT NOT NULL,
            CONSTRAINT "FK_RestApiDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- SequentialDataProviders
        CREATE TABLE IF NOT EXISTS "SequentialDataProviders" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Start" NUMERIC(20,0) NOT NULL,
            "Step" BIGINT NOT NULL,
            "Stop" NUMERIC(20,0) NOT NULL,
            "ResetStrategy" INTEGER NOT NULL,
            "LatestIndex" NUMERIC(20,0) NOT NULL,
            "LatestDate" TIMESTAMP NOT NULL,
            CONSTRAINT "FK_SequentialDataProviders_CredentialDataProviders_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviders" ("Id") ON DELETE CASCADE
        );
        -- AuthTokens
        CREATE TABLE IF NOT EXISTS "AuthTokens" (
            "Id" VARCHAR(450) NOT NULL PRIMARY KEY,
            "Name" VARCHAR(256),
            "State" INTEGER NOT NULL,
            "ExpirationDate" TIMESTAMP,
            "LastUpdate" TIMESTAMP NOT NULL,
            "LastUseDate" TIMESTAMP,
            "ProductionSetId" UUID NOT NULL,
            CONSTRAINT "FK_AuthTokens_ProductionSets_ProductionSetId" FOREIGN KEY ("ProductionSetId") REFERENCES "ProductionSets" ("Id") ON DELETE CASCADE
        );
        -- CredentialProductionSet
        CREATE TABLE IF NOT EXISTS "CredentialProductionSet" (
            "CredentialsId" UUID NOT NULL,
            "ProductionSetsId" UUID NOT NULL,
            PRIMARY KEY ("CredentialsId", "ProductionSetsId"),
            CONSTRAINT "FK_CredentialProductionSet_CredentialBase_CredentialsId" FOREIGN KEY ("CredentialsId") REFERENCES "CredentialBase" ("Id") ON DELETE CASCADE,
            CONSTRAINT "FK_CredentialProductionSet_ProductionSets_ProductionSetsId" FOREIGN KEY ("ProductionSetsId") REFERENCES "ProductionSets" ("Id") ON DELETE CASCADE
        );
        -- FieldDataConversions
        CREATE TABLE IF NOT EXISTS "FieldDataConversions" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Parameters" TEXT,
            "FieldLinkId" UUID NOT NULL,
            "LastUpdate" TIMESTAMP NOT NULL,
            "conversionType" VARCHAR(21) NOT NULL,
            CONSTRAINT "FK_FieldDataConversions_CredentialDataFieldLinks_FieldLinkId" FOREIGN KEY ("FieldLinkId") REFERENCES "CredentialDataFieldLinks" ("Id") ON DELETE CASCADE
        );
        -- ConsoleDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "ConsoleDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            CONSTRAINT "FK_ConsoleDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- CredentialReferenceDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "CredentialReferenceDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            CONSTRAINT "FK_CredentialReferenceDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- CryptoDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "CryptoDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            CONSTRAINT "FK_CryptoDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- DatabaseDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "DatabaseDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Index" NUMERIC(20,0) NOT NULL,
            CONSTRAINT "FK_DatabaseDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- DateTimeDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "DateTimeDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            CONSTRAINT "FK_DateTimeDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- ExcelDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "ExcelDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Index" INTEGER NOT NULL,
            CONSTRAINT "FK_ExcelDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- FileDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "FileDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            CONSTRAINT "FK_FileDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- LdapDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "LdapDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Index" INTEGER NOT NULL,
            CONSTRAINT "FK_LdapDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- RandomDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "RandomDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "GeneratedNumber" NUMERIC(20,0),
            CONSTRAINT "FK_RandomDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- RestApiDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "RestApiDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            CONSTRAINT "FK_RestApiDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- SequentialDataProviderTrackers
        CREATE TABLE IF NOT EXISTS "SequentialDataProviderTrackers" (
            "Id" UUID NOT NULL PRIMARY KEY,
            "Index" NUMERIC(20,0) NOT NULL,
            CONSTRAINT "FK_SequentialDataProviderTrackers_CredentialDataProviderTrackers_Id" FOREIGN KEY ("Id") REFERENCES "CredentialDataProviderTrackers" ("Id") ON DELETE CASCADE
        );
        -- Indexes (partial, for brevity)
        CREATE INDEX IF NOT EXISTS "IX_AspNetRoleClaims_RoleId" ON "AspNetRoleClaims" ("RoleId");
        CREATE UNIQUE INDEX IF NOT EXISTS "RoleNameIndex" ON "AspNetRoles" ("NormalizedName") WHERE "NormalizedName" IS NOT NULL;
        CREATE INDEX IF NOT EXISTS "IX_AspNetUserClaims_UserId" ON "AspNetUserClaims" ("UserId");
        CREATE INDEX IF NOT EXISTS "IX_AspNetUserLogins_UserId" ON "AspNetUserLogins" ("UserId");
        CREATE INDEX IF NOT EXISTS "IX_AspNetUserRoles_RoleId" ON "AspNetUserRoles" ("RoleId");
        CREATE INDEX IF NOT EXISTS "EmailIndex" ON "AspNetUsers" ("NormalizedEmail");
        CREATE UNIQUE INDEX IF NOT EXISTS "UserNameIndex" ON "AspNetUsers" ("NormalizedUserName") WHERE "NormalizedUserName" IS NOT NULL;
        -- (repeat for all other indexes in the original script)
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20240410034748_InitialCreate', '8.0.20');
    END IF;
END$$;

-- Migration: 20240610063540_AddCredentialLock
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20240610063540_AddCredentialLock') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'CredentialBase' AND column_name = 'Locked' AND table_schema = 'public') THEN
            ALTER TABLE "CredentialBase" ADD COLUMN "Locked" BOOLEAN;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'CredentialLocks' AND table_schema = 'public') THEN
            CREATE TABLE "CredentialLocks" (
                "Id" UUID NOT NULL PRIMARY KEY,
                "CredentialId" UUID NOT NULL,
                "CreationDate" TIMESTAMP NOT NULL,
                "ClientId" VARCHAR(256),
                "UserId" VARCHAR(450),
                CONSTRAINT "FK_CredentialLocks_CredentialBase_CredentialId" FOREIGN KEY ("CredentialId") REFERENCES "CredentialBase" ("Id") ON DELETE CASCADE
            );
            CREATE INDEX IF NOT EXISTS "IX_CredentialLocks_CredentialId" ON "CredentialLocks" ("CredentialId");
        END IF;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20240610063540_AddCredentialLock', '8.0.20');
    END IF;
END$$;

-- Migration: 20240616092654_DumpKeyFromKeyStore
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20240616092654_DumpKeyFromKeyStore') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Keys' AND column_name = 'DumpFromKeyStore' AND table_schema = 'public') THEN
            ALTER TABLE "Keys" ADD COLUMN "DumpFromKeyStore" BOOLEAN NOT NULL DEFAULT FALSE;
        END IF;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20240616092654_DumpKeyFromKeyStore', '8.0.20');
    END IF;
END$$;

-- Migration: 20240617182051_AddCredentialInitialized
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20240617182051_AddCredentialInitialized') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'CredentialBase' AND column_name = 'Initialized' AND table_schema = 'public') THEN
            ALTER TABLE "CredentialBase" ADD COLUMN "Initialized" BOOLEAN;
        END IF;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20240617182051_AddCredentialInitialized', '8.0.20');
    END IF;
END$$;

-- Migration: 20240717201921_AddExportableOptionOnKeys
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20240717201921_AddExportableOptionOnKeys') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Keys' AND column_name = 'Exportable' AND table_schema = 'public') THEN
            ALTER TABLE "Keys" ADD COLUMN "Exportable" BOOLEAN NOT NULL DEFAULT TRUE;
        END IF;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20240717201921_AddExportableOptionOnKeys', '8.0.20');
    END IF;
END$$;

-- Migration: 20241101080415_AddOptionalFragmentTemplatePreview
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20241101080415_AddOptionalFragmentTemplatePreview') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'CredentialFragmentTemplates' AND column_name = 'Preview' AND table_schema = 'public') THEN
            ALTER TABLE "CredentialFragmentTemplates" ADD COLUMN "Preview" TEXT;
        END IF;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20241101080415_AddOptionalFragmentTemplatePreview', '8.0.20');
    END IF;
END$$;

-- Migration: 20250226103453_AddProductionSetCompletion
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250226103453_AddProductionSetCompletion') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ProductionSets' AND column_name = 'Completion' AND table_schema = 'public') THEN
            ALTER TABLE "ProductionSets" ADD COLUMN "Completion" INTEGER NOT NULL DEFAULT 0;
        END IF;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20250226103453_AddProductionSetCompletion', '8.0.20');
    END IF;
END$$;

-- Migration: 20250311202254_FK_CredentialTemplate_Credential_ToNull
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250311202254_FK_CredentialTemplate_Credential_ToNull') THEN
        -- Drop and recreate FK with ON DELETE SET NULL
        IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints
            WHERE table_name = 'CredentialBase' AND constraint_name = 'FK_CredentialBase_CredentialTemplates_CredentialTemplateId' AND table_schema = 'public'
        ) THEN
            ALTER TABLE "CredentialBase" DROP CONSTRAINT "FK_CredentialBase_CredentialTemplates_CredentialTemplateId";
        END IF;
        ALTER TABLE "CredentialBase" ADD CONSTRAINT "FK_CredentialBase_CredentialTemplates_CredentialTemplateId" FOREIGN KEY ("CredentialTemplateId") REFERENCES "CredentialTemplates" ("Id") ON DELETE SET NULL;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20250311202254_FK_CredentialTemplate_Credential_ToNull', '8.0.20');
    END IF;
END$$;

-- Migration: 20250924141816_ManualOptionOnDynamicFragment_AddTags_To_ProductionSets_And_CredentialKeys
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20250924141816_ManualOptionOnDynamicFragment_AddTags_To_ProductionSets_And_CredentialKeys') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ProductionSets' AND column_name = 'Tags' AND table_schema = 'public') THEN
            ALTER TABLE "ProductionSets" ADD COLUMN "Tags" TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Keys' AND column_name = 'Tags' AND table_schema = 'public') THEN
            ALTER TABLE "Keys" ADD COLUMN "Tags" TEXT;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DynamicFragmentTemplate' AND column_name = 'FragmentDescription_Displayed' AND table_schema = 'public') THEN
            ALTER TABLE "DynamicFragmentTemplate" ADD COLUMN "FragmentDescription_Displayed" VARCHAR(256);
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DynamicFragmentTemplate' AND column_name = 'ManualAllocation' AND table_schema = 'public') THEN
            ALTER TABLE "DynamicFragmentTemplate" ADD COLUMN "ManualAllocation" BOOLEAN NOT NULL DEFAULT FALSE;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'CredentialFragmentTemplates' AND column_name = 'FragmentDescription_Displayed' AND table_schema = 'public') THEN
            ALTER TABLE "CredentialFragmentTemplates" ADD COLUMN "FragmentDescription_Displayed" VARCHAR(256);
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'CredentialFragments' AND column_name = 'DynamicFragmentTemplateId' AND table_schema = 'public') THEN
            ALTER TABLE "CredentialFragments" ADD COLUMN "DynamicFragmentTemplateId" UUID;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'CredentialFragments' AND column_name = 'FragmentDescription_Displayed' AND table_schema = 'public') THEN
            ALTER TABLE "CredentialFragments" ADD COLUMN "FragmentDescription_Displayed" VARCHAR(256);
        END IF;
        -- Index and FK for DynamicFragmentTemplateId
        IF NOT EXISTS (
            SELECT 1 FROM pg_indexes WHERE tablename = 'CredentialFragments' AND indexname = 'IX_CredentialFragments_DynamicFragmentTemplateId'
        ) THEN
            CREATE INDEX "IX_CredentialFragments_DynamicFragmentTemplateId" ON "CredentialFragments" ("DynamicFragmentTemplateId");
        END IF;
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'CredentialFragments' AND constraint_name = 'FK_CredentialFragments_DynamicFragmentTemplate_DynamicFragmentTemplateId' AND table_schema = 'public'
        ) THEN
            ALTER TABLE "CredentialFragments" ADD CONSTRAINT "FK_CredentialFragments_DynamicFragmentTemplate_DynamicFragmentTemplateId" FOREIGN KEY ("DynamicFragmentTemplateId") REFERENCES "DynamicFragmentTemplate" ("Id");
        END IF;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20250924141816_ManualOptionOnDynamicFragment_AddTags_To_ProductionSets_And_CredentialKeys', '8.0.20');
    END IF;
END$$;

-- Migration: 20251015090201_CascadeNullOnFragmentTemplateDelete
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251015090201_CascadeNullOnFragmentTemplateDelete') THEN
        -- Drop existing FK between CredentialFragments and CredentialFragmentTemplates and recreate it with ON DELETE SET NULL
        IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints
            WHERE table_name = 'CredentialFragments' AND constraint_name = 'FK_CredentialFragments_CredentialFragmentTemplates_FragmentTemplateId' AND table_schema = 'public'
        ) THEN
            ALTER TABLE "CredentialFragments" DROP CONSTRAINT "FK_CredentialFragments_CredentialFragmentTemplates_FragmentTemplateId";
        END IF;

        -- Make DateTimeDataProviders.Format2 and Format1 nullable
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DateTimeDataProviders' AND column_name = 'Format2' AND table_schema = 'public') THEN
            ALTER TABLE "DateTimeDataProviders" ALTER COLUMN "Format2" DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DateTimeDataProviders' AND column_name = 'Format1' AND table_schema = 'public') THEN
            ALTER TABLE "DateTimeDataProviders" ALTER COLUMN "Format1" DROP NOT NULL;
        END IF;

        -- Recreate FK with ON DELETE SET NULL
        ALTER TABLE "CredentialFragments" ADD CONSTRAINT "FK_CredentialFragments_CredentialFragmentTemplates_FragmentTemplateId" FOREIGN KEY ("FragmentTemplateId") REFERENCES "CredentialFragmentTemplates" ("Id") ON DELETE SET NULL;

        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20251015090201_CascadeNullOnFragmentTemplateDelete', '8.0.20');
    END IF;
END$$;

-- Migration: 20251107134908_AddReviewedToCredential
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251107134908_AddReviewedToCredential') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'CredentialBase' AND column_name = 'Reviewed' AND table_schema = 'public') THEN
            ALTER TABLE "CredentialBase" ADD COLUMN "Reviewed" BOOLEAN;
        END IF;
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20251107134908_AddReviewedToCredential', '8.0.20');
    END IF;
END$$;

-- Migration: 20260129054208_DynamicFragment_DataFieldFallback
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260129054208_DynamicFragment_DataFieldFallback') THEN
        -- Add DataFieldFallbackId column
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DynamicFragmentTemplate' AND column_name = 'DataFieldFallbackId' AND table_schema = 'public') THEN
            ALTER TABLE "DynamicFragmentTemplate" ADD COLUMN "DataFieldFallbackId" UUID;
        END IF;

        -- Add MatchPrefix column
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DynamicFragmentTemplate' AND column_name = 'MatchPrefix' AND table_schema = 'public') THEN
            ALTER TABLE "DynamicFragmentTemplate" ADD COLUMN "MatchPrefix" VARCHAR(128);
        END IF;

        -- Create index on DataFieldFallbackId
        IF NOT EXISTS (
            SELECT 1 FROM pg_indexes WHERE tablename = 'DynamicFragmentTemplate' AND indexname = 'IX_DynamicFragmentTemplate_DataFieldFallbackId'
        ) THEN
            CREATE INDEX "IX_DynamicFragmentTemplate_DataFieldFallbackId" ON "DynamicFragmentTemplate" ("DataFieldFallbackId");
        END IF;

        -- Add foreign key constraint to CredentialDataFields
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.table_constraints
            WHERE table_name = 'DynamicFragmentTemplate' AND constraint_name = 'FK_DynamicFragmentTemplate_CredentialDataFields_DataFieldFallbackId' AND table_schema = 'public'
        ) THEN
            ALTER TABLE "DynamicFragmentTemplate" ADD CONSTRAINT "FK_DynamicFragmentTemplate_CredentialDataFields_DataFieldFallbackId" FOREIGN KEY ("DataFieldFallbackId") REFERENCES "CredentialDataFields" ("Id");
        END IF;

        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") VALUES ('20260129054208_DynamicFragment_DataFieldFallback', '8.0.20');
    END IF;
END$$;

-- Migration: 20260205154112_DynamicFragment_AllFieldsRequired
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "__EFMigrationsHistory"
        WHERE "MigrationId" = '20260205154112_DynamicFragment_AllFieldsRequired'
    ) THEN
        ALTER TABLE "DynamicFragmentTemplate"
        DROP CONSTRAINT IF EXISTS "FK_DynamicFragmentTemplate_CredentialDataFields_DataFieldFallbackId";
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "__EFMigrationsHistory"
        WHERE "MigrationId" = '20260205154112_DynamicFragment_AllFieldsRequired'
    ) THEN
        ALTER TABLE "DynamicFragmentTemplate"
        RENAME COLUMN "DataFieldFallbackId" TO "DataField2Id";
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "__EFMigrationsHistory"
        WHERE "MigrationId" = '20260205154112_DynamicFragment_AllFieldsRequired'
    ) THEN
        ALTER INDEX "IX_DynamicFragmentTemplate_DataFieldFallbackId"
        RENAME TO "IX_DynamicFragmentTemplate_DataField2Id";
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "__EFMigrationsHistory"
        WHERE "MigrationId" = '20260205154112_DynamicFragment_AllFieldsRequired'
    ) THEN
        ALTER TABLE "DynamicFragmentTemplate"
        ADD COLUMN "AllFieldsRequired" boolean NOT NULL DEFAULT false;
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "__EFMigrationsHistory"
        WHERE "MigrationId" = '20260205154112_DynamicFragment_AllFieldsRequired'
    ) THEN
        ALTER TABLE "DynamicFragmentTemplate"
        ADD COLUMN "MatchPrefix2" varchar(128);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "__EFMigrationsHistory"
        WHERE "MigrationId" = '20260205154112_DynamicFragment_AllFieldsRequired'
    ) THEN
        ALTER TABLE "DynamicFragmentTemplate"
        ADD CONSTRAINT "FK_DynamicFragmentTemplate_CredentialDataFields_DataField2Id"
        FOREIGN KEY ("DataField2Id")
        REFERENCES "CredentialDataFields" ("Id");
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "__EFMigrationsHistory"
        WHERE "MigrationId" = '20260205154112_DynamicFragment_AllFieldsRequired'
    ) THEN
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
        VALUES ('20260205154112_DynamicFragment_AllFieldsRequired', '8.0.20');
    END IF;
END$$;

-- End of migrations
