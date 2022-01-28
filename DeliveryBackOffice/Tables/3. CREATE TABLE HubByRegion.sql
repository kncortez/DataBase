Use DeliveryBackOffice
--****************CREANDO TABLA QUE RELACIONA REGION Y HUB****************
CREATE TABLE HubByRegion(
	IdHubByRegion INT IDENTITY (1,1) NOT NULL,
	HubLogisticId INT NOT NULL, 
	RegionId INT NOT NULL,
	RowStatus BIT NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateCreated DATETIME NOT NULL,
	TokenUpdated NVARCHAR(50),
	DateUpdated DATETIME,	
	CONSTRAINT PK_HubByRegion PRIMARY KEY(IdHubByRegion),
	CONSTRAINT UK_HubLogisticId UNIQUE (HubLogisticId),
	CONSTRAINT FK_HubByRegion_HubLogistic FOREIGN KEY (HubLogisticId) REFERENCES HubLogistics(IdHubLogistic),
	CONSTRAINT FK_HubByRegin_Region FOREIGN KEY (RegionId) REFERENCES CatRegion(IdCatRegion)
);


--Table Description
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Registros de HUBs por región.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion'
--Fields table description    
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion', @level2type=N'COLUMN',@level2name=N'IdHubByRegion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del hub' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion', @level2type=N'COLUMN',@level2name=N'HubLogisticId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de la región' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion', @level2type=N'COLUMN',@level2name=N'RegionId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HubByRegion', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO


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
CREATE NONCLUSTERED INDEX IX_HubLogisticIdRegionId ON dbo.HubByRegion
	(
		HubLogisticId,
		RegionId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.HubByRegion SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
