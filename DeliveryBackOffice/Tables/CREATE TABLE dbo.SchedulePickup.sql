GO
CREATE TABLE dbo.SchedulePickup
	(
	SchedulePickupId bigint NOT NULL IDENTITY (1, 1),
	AccountId bigint NOT NULL,
	StartDate datetime NULL,
	EndDate datetime NULL,
	EstimatedWeight decimal(18, 0) NULL,
	IsLargePackage bit NULL,
	QuantityRegularPackages int NULL,
	QuantityOverDimensionedPackage int NULL,
	SpecialInstructions nvarchar(200) NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Identificador de recolección programada'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'SchedulePickupId'
GO
DECLARE @v sql_variant 
SET @v = N'Cuenta asociada'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'AccountId'
GO
DECLARE @v sql_variant 
SET @v = N'Primer hora de recolección'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'StartDate'
GO
DECLARE @v sql_variant 
SET @v = N'Última hora de recolección'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'EndDate'
GO
DECLARE @v sql_variant 
SET @v = N'Peso estimado'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'EstimatedWeight'
GO
DECLARE @v sql_variant 
SET @v = N'Contiene su recolección paquetes grandes?'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'IsLargePackage'
GO
DECLARE @v sql_variant 
SET @v = N'Cantidad de piezas regulares'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'QuantityRegularPackages'
GO
DECLARE @v sql_variant 
SET @v = N'Cantidad de piezas sobredimensionadas'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'QuantityOverDimensionedPackage'
GO
DECLARE @v sql_variant 
SET @v = N'Instrucciones especiales'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'SpecialInstructions'
GO
DECLARE @v sql_variant 
SET @v = N'Estado del registro'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'RowStatus'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'TokenCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'DateCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'TokenUpdated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SchedulePickup', N'COLUMN', N'DateUpdated'
GO
ALTER TABLE dbo.SchedulePickup ADD CONSTRAINT
	PK_SchedulePickup PRIMARY KEY CLUSTERED 
	(
	SchedulePickupId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.SchedulePickup ADD CONSTRAINT
	FK_SchedulePickup_Account FOREIGN KEY
	(
	AccountId
	) REFERENCES dbo.Account
	(
	AccIdAccount
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 