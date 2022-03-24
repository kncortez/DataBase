USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClosureAccount](
	[IdClosureAccount] [bigint] IDENTITY(1,1) NOT NULL,
	[AccountNumber] [varchar](100) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](250) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdClosureAccount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla ClosureAccount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'IdClosureAccount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de cuenta para los cierres.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'AccountNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la cuenta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la cuenta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se actualizó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar las cuentas que se utilizan para generar cierres en Express Center.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount'
GO