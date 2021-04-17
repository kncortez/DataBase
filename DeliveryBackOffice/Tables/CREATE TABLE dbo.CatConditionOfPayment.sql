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
CREATE TABLE dbo.CatConditionOfPayment
	(
	IdConditionOfPayment int NOT NULL IDENTITY (1, 1),
	ConditionOfPayment nvarchar(50) NOT NULL,
	ConditionOfPaymenDescription nvarchar(200) NULL,
	ConditionOfPaymenAbbreviation nvarchar(20) NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.CatConditionOfPayment ADD CONSTRAINT
	DF_CatConditionOfPayment_RowStatus DEFAULT 'TRUE' FOR RowStatus
GO
ALTER TABLE dbo.CatConditionOfPayment ADD CONSTRAINT
	PK_CatConditionOfPayment PRIMARY KEY CLUSTERED 
	(
	IdConditionOfPayment
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CatConditionOfPayment SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
