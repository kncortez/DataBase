/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.CatCityPlace
	(
	IdCityPlace int NOT NULL IDENTITY (1, 1),
	CityPlace varchar(50) NULL,
	CityPlaceRowStatus bit NULL,
	CityPlaceTokenCreated varchar(50) NULL,
	CityPlaceDateCreated datetime NULL,
	CityPlaceTokenUpdated varchar(50) NULL,
	CityPlaceDateUpdate datetime NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'List of place in the city'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatCityPlace', N'COLUMN', N'CityPlace'
GO
DECLARE @v sql_variant 
SET @v = N'1 active  0 inactive'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatCityPlace', N'COLUMN', N'CityPlaceRowStatus'
GO
ALTER TABLE dbo.CatCityPlace ADD CONSTRAINT
	PK_CatCityPlace PRIMARY KEY CLUSTERED 
	(
	IdCityPlace
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CatCityPlace SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
