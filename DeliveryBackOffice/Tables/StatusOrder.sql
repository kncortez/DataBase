USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[StatusOrder]    Script Date: 3/06/2020 16:54:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[StatusOrder](
	[StatusOrderId] [tinyint] IDENTITY(1,1) NOT NULL,
	[OrderDescription] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED 
(
	[StatusOrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de status order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StatusOrder', @level2type=N'COLUMN',@level2name=N'StatusOrderId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de status order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StatusOrder', @level2type=N'COLUMN',@level2name=N'OrderDescription'
GO


