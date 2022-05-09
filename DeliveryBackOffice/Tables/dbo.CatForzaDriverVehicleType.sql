USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatForzaDriverVehicleType]    Script Date: 4/18/2022 14:18:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatForzaDriverVehicleType](
	[IdCatForzaDriverVehicleType] [int] IDENTITY(1,1) NOT NULL,
	[ForzaDriverVehicleTypeId] [int] NOT NULL,
	[ForzaDriverVehicleDescription] [nvarchar](50) NOT NULL,
	[CatTypeVehicleId] [int] NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCatForzaDriverVehicleType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatForzaDriverVehicleType]  WITH CHECK ADD  CONSTRAINT [FK_CatForzaDriverVehicleType_CatTypeVehicle] FOREIGN KEY([IdCatForzaDriverVehicleType])
REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle])
GO

ALTER TABLE [dbo].[CatForzaDriverVehicleType] CHECK CONSTRAINT [FK_CatForzaDriverVehicleType_CatTypeVehicle]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType', @level2type=N'COLUMN',@level2name=N'IdCatForzaDriverVehicleType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de vehículo en la plataforma de ForzaDriver' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType', @level2type=N'COLUMN',@level2name=N'ForzaDriverVehicleTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de tipo de vehículo de la tabla CatTypeVehicle' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType', @level2type=N'COLUMN',@level2name=N'CatTypeVehicleId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para mapear los tipos de vehículo existentes en la plataforma de ForzaDriver con los tipos de vehículo existentes en DeliveryBackOffice.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatForzaDriverVehicleType'
GO


