USE [DeliveryBackOffice]
GO
/****** Object:  Table [dbo].[TermsAndConditions]    Script Date: 3/03/2022 15:32:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TermsAndConditions](
	[IdTAC] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](250) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdTAC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla TermsAndConditions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions', @level2type=N'COLUMN',@level2name=N'IdTAC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de los términos y condiciones.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de los términos y condiciones.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar los cambios de los términos y condiciones de transporte de Forza Delivery Express.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditions'
GO