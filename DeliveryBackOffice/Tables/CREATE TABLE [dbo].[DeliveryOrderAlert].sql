
CREATE TABLE DeliveryOrderAlert(
	IdDeliveryOrderAlert int identity(1,1) not null,
	GuideSerie varchar(2),
	GuideNumber int,
	ServiceTypeId nvarchar(15),
	AlertDescription nvarchar(500) not null,
	AlertTypeId int,
	RowStatus bit,
	TokenCreated nvarchar(50) not null,
	DateCreated datetime not null,
	TokenUpdated nvarchar(50),
	DateUpdated datetime,
	CONSTRAINT PK_DeliveryOrderAlert PRIMARY KEY (IdDeliveryOrderAlert),
	CONSTRAINT FK_DeliveryOrderAlert_TypeAlertId FOREIGN KEY(AlertTypeId)b REFERENCES CatTypeAlert(IdCatTypeAlert),
	CONSTRAINT FK_DeliveryOrderAlert_TypeServiceId FOREIGN KEY(ServiceTypeId) REFERENCES TypeServiceManagment(IdTypeServiceManagment)
);



EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifiacdor de registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'IdDeliveryOrderAlert'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la gu�a' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de la gu�a' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'ServiceTypeId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripci�n de la alerta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'AlertDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del tipo de alerta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'AlertTypeId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado l�gico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderAlert', @level2type=N'COLUMN',@level2name=N'DateUpdated'
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
CREATE NONCLUSTERED INDEX IX_DeliveryOrderAlert_GuideList ON dbo.DeliveryOrderAlert
	(
		GuideSerie,
		GuideNumber
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.DeliveryOrderAlert SET (LOCK_ESCALATION = TABLE)
GO
COMMIT



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
CREATE NONCLUSTERED INDEX IX_DeliveryOrderAlert_TypeList ON dbo.DeliveryOrderAlert
	(
		AlertTypeId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.DeliveryOrderAlert SET (LOCK_ESCALATION = TABLE)
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
CREATE NONCLUSTERED INDEX IX_DeliveryOrderAlert_ServiceTypeList ON dbo.DeliveryOrderAlert
	(
		ServiceTypeId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.DeliveryOrderAlert SET (LOCK_ESCALATION = TABLE)
GO
COMMIT