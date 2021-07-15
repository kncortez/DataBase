USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[AccountingClosuresDetail]    Script Date: 15/07/2021 14:07:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AccountingClosuresDetail](
	[IdAccountingClosuresDetail] [int] IDENTITY(1,1) NOT NULL,
	[AccountingClosuresHeaderId] [int] NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_AccountingClosuresDetail] PRIMARY KEY CLUSTERED 
(
	[IdAccountingClosuresDetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AccountingClosuresDetail]  WITH CHECK ADD  CONSTRAINT [FK_AccountingClosuresDetail_AccountingClosuresHeader] FOREIGN KEY([AccountingClosuresHeaderId])
REFERENCES [dbo].[AccountingClosuresHeader] ([IdAccountingClosuresHeader])
GO

ALTER TABLE [dbo].[AccountingClosuresDetail] CHECK CONSTRAINT [FK_AccountingClosuresDetail_AccountingClosuresHeader]
GO

ALTER TABLE [dbo].[AccountingClosuresDetail]  WITH CHECK ADD  CONSTRAINT [FK_AccountingClosuresDetail_DeliveryOrder] FOREIGN KEY([GuideSerie], [GuideNumber])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[AccountingClosuresDetail] CHECK CONSTRAINT [FK_AccountingClosuresDetail_DeliveryOrder]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'IdAccountingClosuresDetail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del lote de cierre' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'AccountingClosuresHeaderId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresDetail', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

