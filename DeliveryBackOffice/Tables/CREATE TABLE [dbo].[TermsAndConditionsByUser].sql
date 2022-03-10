USE [DeliveryBackOffice]
GO
/****** Object:  Table [dbo].[TermsAndConditionsByUser]    Script Date: 3/03/2022 17:39:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TermsAndConditionsByUser](
	[IdTACByUser] [bigint] IDENTITY(1,1) NOT NULL,
	[TACId] [bigint] NOT NULL,
	[IdAccount] [bigint] NOT NULL,
	[TAC] [bit] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdTACByUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TermsAndConditionsByUser]  WITH CHECK ADD FOREIGN KEY([IdAccount])
REFERENCES [dbo].[Account] ([AccIdAccount])
GO
ALTER TABLE [dbo].[TermsAndConditionsByUser]  WITH CHECK ADD FOREIGN KEY([TACId])
REFERENCES [dbo].[TermsAndConditions] ([IdTAC])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla TermsAndConditionsByUser.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'IdTACByUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla TermsAndConditions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'TACId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla Account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'IdAccount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado que indica si un usuario ya ha aceptado los términos y condiciones, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'TAC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar si un usuario ha aceptado los términos y condiciones de transporte de Forza Delivery Express' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TermsAndConditionsByUser'
GO