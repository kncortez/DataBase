USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ExtPlatServiceRelationshipWithGuide]    Script Date: 16/08/2021 17:38:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ExtPlatServiceRelationshipWithGuide](
	[IdExtPlatServiceRelationshipWithGuide] [bigint] IDENTITY(1,1) NOT NULL,
	[ExtPlatServiceId] [int] NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[RowStatus] [int] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdExtPlatServiceRelationshipWithGuide] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ExtPlatServiceRelationshipWithGuide]  WITH CHECK ADD  CONSTRAINT [ExtPlatServiceRelationshipWithGuide_Guide_FK] FOREIGN KEY([GuideSerie], [GuideNumber])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[ExtPlatServiceRelationshipWithGuide] CHECK CONSTRAINT [ExtPlatServiceRelationshipWithGuide_Guide_FK]
GO

ALTER TABLE [dbo].[ExtPlatServiceRelationshipWithGuide]  WITH CHECK ADD  CONSTRAINT [ExtPlatServiceRelationshipWithGuide_IdService_FK] FOREIGN KEY([ExtPlatServiceId])
REFERENCES [dbo].[ExtPlatformService] ([IdExtPlatformService])
GO

ALTER TABLE [dbo].[ExtPlatServiceRelationshipWithGuide] CHECK CONSTRAINT [ExtPlatServiceRelationshipWithGuide_IdService_FK]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'IdExtPlatServiceRelationshipWithGuide'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de servicio de plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'ExtPlatServiceId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de la guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatServiceRelationshipWithGuide', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO


