USE	DeliveryBackOffice
CREATE TABLE CatTypeAlert(
	IdCatTypeAlert int identity(1,1) not null,
	AlertName varchar(15),
	RowStatus bit,
	TokenCreated nvarchar(50) not null,
	DateCreated datetime not null,
	TokenUpdated nvarchar(50),
	DateUpdated datetime,
	CONSTRAINT PK_CatAlertStatus PRIMARY KEY (IdCatTypeAlert)
);
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifiacdor de registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeAlert', @level2type=N'COLUMN',@level2name=N'IdCatTypeAlert'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripci�n del tipo de alerta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeAlert', @level2type=N'COLUMN',@level2name=N'AlertName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado l�gico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeAlert', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeAlert', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeAlert', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeAlert', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeAlert', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
