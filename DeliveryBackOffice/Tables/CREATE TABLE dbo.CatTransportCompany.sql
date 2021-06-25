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
ALTER TABLE dbo.CatCountry SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.CatTransportCompany
	(
	IdTransportCompany int NOT NULL IDENTITY (1, 1),
	TransportCompanyName nvarchar(50) NULL,
	TransportCompanyDescription varchar(200) NULL,
	TansportCompanyAbbreviation nvarchar(10) NULL,
	CountryID varchar(2) NULL,
	RowStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DataUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.CatTransportCompany ADD CONSTRAINT
	DF_CatTransportCompany_RowStatus DEFAULT 'TRUE' FOR RowStatus
GO
ALTER TABLE dbo.CatTransportCompany ADD CONSTRAINT
	PK_CatTransportCompany PRIMARY KEY CLUSTERED 
	(
	IdTransportCompany
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CatTransportCompany ADD CONSTRAINT
	FK_CatTransportCompany_CatCountry FOREIGN KEY
	(
	CountryID
	) REFERENCES dbo.CatCountry
	(
	IdCountry
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CatTransportCompany SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
