USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[AccountBankFormatRule]    Script Date: 22/12/2021 15:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AccountBankFormatRule](
    [IdAccountBankFormatRule] [int] IDENTITY(1,1),
    [DeliveryBankId] [int] NOT NULL,
    [CatBankAccountTypeId] [int] NOT NULL,
    [MinimumLength] [int] NULL,
    [MaximumLength] [int] NULL,
    [StartsWith] [varchar](150) NULL,
    [Complete] [bit] NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_AccountBankFormatRule_DeliveryBankId_CatBankAccountTypeId] PRIMARY KEY CLUSTERED 
(
	[IdAccountBankFormatRule] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AccountBankFormatRule]  WITH CHECK ADD  CONSTRAINT [FK_AccountBankFormatRule_DeliveryBankId] FOREIGN KEY([DeliveryBankId])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[AccountBankFormatRule] CHECK CONSTRAINT [FK_AccountBankFormatRule_DeliveryBankId]
GO

ALTER TABLE [dbo].[AccountBankFormatRule]  WITH CHECK ADD  CONSTRAINT [FK_AccountBankFormatRule_CatBankAccountTypeId] FOREIGN KEY([CatBankAccountTypeId])
REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType])
GO

ALTER TABLE [dbo].[AccountBankFormatRule] CHECK CONSTRAINT [FK_AccountBankFormatRule_CatBankAccountTypeId]
GO

ALTER TABLE [dbo].[AccountBankFormatRule] ADD CONSTRAINT [df_AccountBankFormatRule_RowStatus] DEFAULT 'TRUE' FOR RowStatus;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla AccountBankFormatRule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'IdAccountBankFormatRule'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla DeliveryBank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'DeliveryBankId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatBankAccountType..' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'CatBankAccountTypeId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Longitud minima del número de cuenta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'MinimumLength'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Longitud máxima del número de cuenta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'MaximumLength'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lista de números separados por coma con los que puede iniciar un número de cuenta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'StartsWith'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Completar con ceros a la izquierda un número de cuenta, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'Complete'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar las reglas del formato para una cuenta de banco.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountBankFormatRule'
GO