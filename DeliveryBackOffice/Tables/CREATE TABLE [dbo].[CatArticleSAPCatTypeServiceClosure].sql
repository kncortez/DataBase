USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatArticleSAPCatTypeServiceClosure]    Script Date: 02/02/2022 17:34:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatArticleSAPCatTypeServiceClosure](
	[IdCatArticleSAPCatTypeServiceClosure] [int] IDENTITY(1,1) NOT NULL,
	[IdCatArticleSAP] [int] NULL,
	[IdTypeService] [int] NULL,
	[SAPCode] [nvarchar](50) NULL,
 CONSTRAINT [PK_CatArticleSAPCatTypeServiceClosure] PRIMARY KEY CLUSTERED 
(
	[IdCatArticleSAPCatTypeServiceClosure] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatArticleSAPCatTypeServiceClosure]  WITH CHECK ADD  CONSTRAINT [FK_CatArticleSAPCatTypeServiceClosure_IdTypeService] FOREIGN KEY([IdTypeService])
REFERENCES [dbo].[CatTypeServiceClosure] ([IdTypeService])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[CatArticleSAPCatTypeServiceClosure] CHECK CONSTRAINT [FK_CatArticleSAPCatTypeServiceClosure_IdTypeService]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatArticleSAPCatTypeServiceClosure', @level2type=N'COLUMN',@level2name=N'IdCatArticleSAPCatTypeServiceClosure'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID foranea ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatArticleSAPCatTypeServiceClosure', @level2type=N'COLUMN',@level2name=N'IdCatArticleSAP'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID foranea de servicios ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatArticleSAPCatTypeServiceClosure', @level2type=N'COLUMN',@level2name=N'IdTypeService'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatArticleSAPCatTypeServiceClosure', @level2type=N'COLUMN',@level2name=N'SAPCode'
GO


