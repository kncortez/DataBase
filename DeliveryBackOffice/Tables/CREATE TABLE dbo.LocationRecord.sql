USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[LocationRecord]    Script Date: 5/2/2022 11:45:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LocationRecord](
	[IdLocationRecord] [int] IDENTITY(1,1) NOT NULL,
	[SocialSecurityId] [nvarchar](200) NULL,
	[Phone] [nvarchar](10) NULL,
	[Address] [nvarchar](600) NULL,
	[Accuracy] [nvarchar](20) NULL,
	[Latitud] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_LocationRecord_IdLocationRecord] PRIMARY KEY CLUSTERED 
(
	[IdLocationRecord] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[LocationRecord] ADD  CONSTRAINT [df_LocationRecord_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla LocationRecord.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'IdLocationRecord'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de seguridad social que se registró en la ubicación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'SocialSecurityId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de telefono que se registró en la ubicación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'Phone'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección de la ubicación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'Address'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exactitud de la ubicación, menor valor más exacto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'Accuracy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Latitud de la ubicación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'Latitud'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Longitude de la ubicación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'Longitude'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar el historico de ubicaciones basada en número de seguridad social o número de teléfono.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationRecord'
GO


