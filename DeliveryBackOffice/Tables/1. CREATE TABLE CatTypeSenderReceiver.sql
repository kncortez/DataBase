Use DeliveryBackOffice
--****************CREANDO TABLA TIPOS DE PILOTOS****************
CREATE TABLE CatTypeSenderReceiver(
	IdCatTypeSenderReceiver INT IDENTITY(1,1) NOT NULL,
	TypeName	NVARCHAR(30) NOT NULL,
	RowStatus BIT NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateCreated DATETIME NOT NULL,
	TokenUpdated NVARCHAR(50),
	DateUpdated DATETIME,	
	CONSTRAINT PK_CatTypeSenderReceiver PRIMARY KEY (IdCatTypeSenderReceiver)
);

--Table Description
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catalogo de tipos de piloto.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeSenderReceiver'
--Fields table description
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeSenderReceiver', @level2type=N'COLUMN',@level2name=N'IdCatTypeSenderReceiver'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del tipo de piloto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeSenderReceiver', @level2type=N'COLUMN',@level2name=N'TypeName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeSenderReceiver', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeSenderReceiver', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeSenderReceiver', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeSenderReceiver', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeSenderReceiver', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO