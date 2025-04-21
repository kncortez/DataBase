CREATE TABLE [dbo].[CustomerCODLog] (
    [IdCustomerCODLog]        INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustomerId]              INT           NULL,
    [VisitPointId]            INT           NULL,
    [IsCOD]                   INT           NULL,
    [CODExcludePriceShipping] INT           NULL,
    [CODExcludeComission]     INT           NULL,
    [CODIdBank]               INT           NULL,
    [CODAccountName]          VARCHAR (100) NULL,
    [CODAccountNumber]        VARCHAR (50)  NULL,
    [CODAccountTypeId]        INT           NULL,
    [CODCurrencyId]           INT           NULL,
    [CODCatBatchType]         BIGINT        NULL,
    [CODCatBatchFrequency]    BIGINT        NULL,
    [CODBillingTimeId]        INT           NULL,
    [CODBillingVolumeId]      INT           NULL,
    [CODBillingCutOfDate]     DATETIME      NULL,
    [DateRegister]            DATETIME      NULL,
    [TokenRegister]           VARCHAR (50)  NULL,
    [DateUpdated]             DATETIME      NULL,
    [TokenUpdated]            VARCHAR (50)  NULL,
    CONSTRAINT [PK_CustomerCODLog] PRIMARY KEY CLUSTERED ([IdCustomerCODLog] ASC),
    CONSTRAINT [FK_CustomerCODLog_CatBankAccountType] FOREIGN KEY ([CODAccountTypeId]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
    CONSTRAINT [FK_CustomerCODLog_CODBillingTimeId] FOREIGN KEY ([CODBillingTimeId]) REFERENCES [dbo].[CatBillingTime] ([IdCatBillingTime]),
    CONSTRAINT [FK_CustomerCODLog_CODBillingVolumeId] FOREIGN KEY ([CODBillingVolumeId]) REFERENCES [dbo].[CatBillingVolume] ([IdCatBillingVolume]),
    CONSTRAINT [FK_CustomerCODLog_CODCatBatchFrequency] FOREIGN KEY ([CODCatBatchFrequency]) REFERENCES [dbo].[CatBatchFrequencyCOD] ([CatBatchFrequencyCODId]),
    CONSTRAINT [FK_CustomerCODLog_CODCatBatchType] FOREIGN KEY ([CODCatBatchType]) REFERENCES [dbo].[CatBatchTypeCOD] ([CatBatchTypeCODId]),
    CONSTRAINT [FK_CustomerCODLog_CODCurrencyId] FOREIGN KEY ([CODCurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id]),
    CONSTRAINT [FK_CustomerCODLog_CODIdBank] FOREIGN KEY ([CODIdBank]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [FK_CustomerCODLog_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_CustomerCODLog_VisitPointId] FOREIGN KEY ([VisitPointId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);


GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador unico de registro log COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'IdCustomerCODLog'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de usuario corporativo con tabla Customer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de punto de visita asociado al registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'VisitPointId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado booleano que indica si esta activo o inactivo para guias COD (0: Inactivo, 1:activo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'IsCOD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado booleano que indica si puede excluir cobro de envio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODExcludePriceShipping'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado booleano que indica si puede excluir cobro de comision' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODExcludeComission'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de banco asociado a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODIdBank'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de cuenta bancaria asociada a cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODAccountName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de cuenta bancaria asociado a cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODAccountNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de tipo de cuenta bancaria asociada a cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODAccountTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de tipo de moneda asociada a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODCurrencyId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Formato de lote asociado a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODCatBatchType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Frecuencia de deposito asociada a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODCatBatchFrequency'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de Tiempo de Facturacion asociado a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODBillingTimeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Volumen de facturacion asociado a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODBillingVolumeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de corte asociada a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODBillingCutOfDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro de Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'DateRegister'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de registro de Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'TokenRegister'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de Actualizacion de Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de registro de logs para clientes corporativos que habilitan o deshabilitan guias COD en Socio de Negocio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog'
GO


