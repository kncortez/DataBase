CREATE TABLE [dbo].[CustomerCODLog] (
    [IdCustomerCODLog]        INT           IDENTITY (1, 1) NOT NULL,
    [CustomerId]              INT           NULL,
    [isCOD]                   INT           NULL,
    [CODExcludePriceShipping] INT           NULL,
    [CODExcludeComission]     INT           NULL,
    [CODIdBank]               INT           NULL,
    [CODAccountName]          VARCHAR (100) NULL,
    [CODAccountNumber]        INT           NULL,
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
    PRIMARY KEY CLUSTERED ([IdCustomerCODLog] ASC),
    FOREIGN KEY ([CODAccountTypeId]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
    FOREIGN KEY ([CODBillingTimeId]) REFERENCES [dbo].[CatBillingTime] ([IdCatBillingTime]),
    FOREIGN KEY ([CODBillingVolumeId]) REFERENCES [dbo].[CatBillingVolume] ([IdCatBillingVolume]),
    FOREIGN KEY ([CODCatBatchFrequency]) REFERENCES [dbo].[CatBatchFrequencyCOD] ([CatBatchFrequencyCODId]),
    FOREIGN KEY ([CODCatBatchType]) REFERENCES [dbo].[CatBatchTypeCOD] ([CatBatchTypeCODId]),
    FOREIGN KEY ([CODCurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id]),
    FOREIGN KEY ([CODIdBank]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de Actualizacion de Log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion de Log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de registro de Log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'TokenRegister';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de registro de Log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'DateRegister';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de corte asociada a cuenta bancaria de cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODBillingCutOfDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Volumen de facturacion asociado a cuenta bancaria de cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODBillingVolumeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de Tiempo de Facturacion asociado a cuenta bancaria de cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODBillingTimeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Frecuencia de deposito asociada a cuenta bancaria de cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODCatBatchFrequency';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Formato de lote asociado a cuenta bancaria de cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODCatBatchType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tipo de moneda asociada a cuenta bancaria de cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODCurrencyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tipo de cuenta bancaria asociada a cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODAccountTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de cuenta bancaria asociado a cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODAccountNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de cuenta bancaria asociada a cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODAccountName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de banco asociado a cuenta bancaria de cliente COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODIdBank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado booleano que indica si puede excluir cobro de comision', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODExcludeComission';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado booleano que indica si puede excluir cobro de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CODExcludePriceShipping';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado booleano que indica si esta activo o inactivo para guias COD (0: Inactivo, 1:activo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'isCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de usuario corporativo con tabla Customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador unico de registro log COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog', @level2type = N'COLUMN', @level2name = N'IdCustomerCODLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de logs para clientes corporativos que habilitan o deshabilitan guias COD en Socio de Negocio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerCODLog';

