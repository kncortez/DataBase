CREATE TABLE SaleAdvisorbyUser(
	idSaleAdvisorbyUser int identity(1,1) not null,
	UserId bigint not null,
	UserName nvarchar(50) not null,
	SaleAdvisorId int not null,
	RowStatus bit not null,
	TokenCreated nvarchar(50) not null,
	DateCreated datetime not null,
	TokenUpdated nvarchar(50),
	DateUpdated datetime,
	CONSTRAINT PK_SaleAdvisorbyUser PRIMARY KEY (idSaleAdvisorbyUser),
	CONSTRAINT FK_SaleAdvisorbyUserUserId FOREIGN KEY (UserId,UserName) REFERENCES InternalUser(IdUser,Username),
	CONSTRAINT FK_InternalUserSaleAdvisroId FOREIGN KEY (SaleAdvisorId) REFERENCES CatSaleAdvisor(IdSaleAdvisor),
	CONSTRAINT UK_SaleAdvisorbyUser UNIQUE (UserId,SaleAdvisorId)	
);

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
CREATE NONCLUSTERED INDEX IX_SaleAdvisorbyUserUserId ON dbo.SaleAdvisorbyUser
	(
		UserId,
		UserName
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.SaleAdvisorbyUser SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


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
CREATE NONCLUSTERED INDEX IX_UseIdSaleAdvisorId ON dbo.SaleAdvisorbyUser
	(
		UserId,
		SaleAdvisorId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.SaleAdvisorbyUser SET (LOCK_ESCALATION = TABLE)
GO
COMMIT




EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del registro ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'idSaleAdvisorbyUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de usuario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de usuario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del código del vendedor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'SaleAdvisorId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SaleAdvisorbyUser', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO