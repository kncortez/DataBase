USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ServiceProvinceConfiguration]    Script Date: 3/7/2022 4:47:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServiceProvinceConfiguration](
	[IdServiceProvinceConfiguration] [int] IDENTITY(1,1) NOT NULL,
	[CatConfigurableServiceId] [int] NOT NULL,
	[ProvinceId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdServiceProvinceConfiguration] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ServiceProvinceConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_ServiceProvinceConfiguration_CatConfigurableService] FOREIGN KEY([CatConfigurableServiceId])
REFERENCES [dbo].[CatConfigurableService] ([IdCatConfigurableService])
GO

ALTER TABLE [dbo].[ServiceProvinceConfiguration] CHECK CONSTRAINT [FK_ServiceProvinceConfiguration_CatConfigurableService]
GO

ALTER TABLE [dbo].[ServiceProvinceConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_ServiceProvinceConfiguration_Province] FOREIGN KEY([ProvinceId])
REFERENCES [dbo].[Province] ([IdProvince])
GO

ALTER TABLE [dbo].[ServiceProvinceConfiguration] CHECK CONSTRAINT [FK_ServiceProvinceConfiguration_Province]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration', @level2type=N'COLUMN',@level2name=N'IdServiceProvinceConfiguration'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del servicio en la tabla CatConfigurableService' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration', @level2type=N'COLUMN',@level2name=N'CatConfigurableServiceId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del departamento en la tabla Province' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration', @level2type=N'COLUMN',@level2name=N'ProvinceId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de departamentos a considerar durante la ejecución de un servicio configurable' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceProvinceConfiguration'
GO


