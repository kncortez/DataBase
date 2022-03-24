USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CatClosureAccount](
	[IdCatClosureAccount] [bigint] IDENTITY(1,1) NOT NULL,
	[ClosureAccountId] [bigint] NOT NULL,
	[TypeService] [int] NOT NULL,
	[TypeOfInOutOfMoney] [int] NOT NULL,
	[PayTime] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCatClosureAccount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
GO

ALTER TABLE [dbo].[CatClosureAccount]  WITH CHECK ADD FOREIGN KEY([ClosureAccountId])
REFERENCES [dbo].[ClosureAccount] ([IdClosureAccount])
GO
ALTER TABLE [dbo].[CatClosureAccount]  WITH CHECK ADD FOREIGN KEY([TypeService])
REFERENCES [dbo].[CatTypeServiceClosure] ([IdTypeService])
GO
ALTER TABLE [dbo].[CatClosureAccount]  WITH CHECK ADD FOREIGN KEY([TypeOfInOutOfMoney])
REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id])
GO
ALTER TABLE [dbo].[CatClosureAccount]  WITH CHECK ADD FOREIGN KEY([PayTime])
REFERENCES [dbo].[CatPaymentTime] ([TimePlaId])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatClosureAccount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'IdCatClosureAccount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de de la tabla ClosureAccount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'ClosureAccountId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatTypeServiceClosure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'TypeService'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla ctgTypeOfInOutOfMoney.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'TypeOfInOutOfMoney'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatPaymentTime.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'PayTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se actualizó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar las cuentas de Express Center junto con el tipo de servicio y tipo de pago que reciben.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatClosureAccount'
GO