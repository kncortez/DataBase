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
ALTER TABLE dbo.RegisterUser ADD
	UsrIdEmploye bigint NULL
GO
ALTER TABLE dbo.RegisterUser SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.InternalUser
	(
	IdUser bigint NOT NULL,
	Username nvarchar(50) NOT NULL,
	IdEmployee nvarchar(50) NULL,
	RegisterUserID bigint NULL,
	RowStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.InternalUser ADD CONSTRAINT
	DF_InternalUser_RowStatus DEFAULT 'TRUE' FOR RowStatus
GO
ALTER TABLE dbo.InternalUser ADD CONSTRAINT
	PK_InternalUser PRIMARY KEY CLUSTERED 
	(
	IdUser,
	Username
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.InternalUser ADD CONSTRAINT
	FK_InternalUser_RegisterUser FOREIGN KEY
	(
	RegisterUserID
	) REFERENCES dbo.RegisterUser
	(
	UsrIdUser
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.InternalUser SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
