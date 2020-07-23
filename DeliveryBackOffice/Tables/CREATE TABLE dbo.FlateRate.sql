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
CREATE TABLE dbo.FlateRate
	(
	IdRate int NOT NULL IDENTITY (1, 1),
	IdDimensional int NULL,
	IdSegmentArea int NULL,
	ExceededRate bit NULL,
	PriceRate decimal(18, 2) NULL,
	AdicionalCostPerUnit decimal(18, 2) NULL,
	IdCurrency int NULL,
	IdCountry nvarchar(2) NULL,
	FlatRateStatus bit NULL,
	IdRateCategory int NULL,
	DateFromValid datetime NULL,
	DateExpired datetime NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.FlateRate ADD CONSTRAINT
	PK_FlateRate PRIMARY KEY CLUSTERED 
	(
	IdRate
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.FlateRate SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
