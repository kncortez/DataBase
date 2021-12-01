USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Contingency]    Script Date: 29/11/2021 15:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Contingency](
    [IdContingency] [int] IDENTITY(1,1) NOT NULL,
	[DeliveryOrderBySettlementId] [bigint] NOT NULL,
	[Type] [varchar](10) NOT NULL,
    [Value] [decimal](10, 2) NOT NULL,
    [Description] [nvarchar](500) NULL,
    [TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
 CONSTRAINT [PK_Contingency_IdContingency] PRIMARY KEY CLUSTERED 
(
	[IdContingency] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Contingency]  WITH CHECK ADD  CONSTRAINT [FK_Contingency_DeliveryOrderBySettlementId] FOREIGN KEY([DeliveryOrderBySettlementId])
REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID])
GO

ALTER TABLE [dbo].[Contingency] CHECK CONSTRAINT [FK_Contingency_DeliveryOrderBySettlementId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla Contingency, que indica el id de la contingencia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contingency', @level2type=N'COLUMN',@level2name=N'IdContingency'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla DeliveryOrderBySettlement, que indica el id del manifiesto.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contingency', @level2type=N'COLUMN',@level2name=N'DeliveryOrderBySettlementId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de la contingencia, FALTANTE o SOBRANTE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contingency', @level2type=N'COLUMN',@level2name=N'Type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor faltante o sobrante.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contingency', @level2type=N'COLUMN',@level2name=N'Value'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la contingencia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contingency', @level2type=N'COLUMN',@level2name=N'Description'
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contingency', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Contingency', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
