CREATE TABLE [dbo].[CatSubscriptionDiscountRange] (
    [IdCatSubscriptionDiscountRange] INT            IDENTITY (1, 1) NOT NULL,
    [CatSubscriptionId]              INT            NOT NULL,
    [DiscountLowServiceRange]        INT            NOT NULL,
    [DiscountTopServiceRange]        INT            NULL,
    [ValueTypeId]                    INT            NOT NULL,
    [DiscountValue]                  DECIMAL (5, 2) NOT NULL,
    [RowStatus]                      BIT            CONSTRAINT [DF_CatSubscriptionDiscountRange_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                   NVARCHAR (50)  NOT NULL,
    [DateCreated]                    DATETIME       NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL,
    CONSTRAINT [PK_CatSubscriptionDiscountRange] PRIMARY KEY CLUSTERED ([IdCatSubscriptionDiscountRange] ASC),
    CONSTRAINT [FK_CatSubscriptionDiscountRange_IdCatSubscription] FOREIGN KEY ([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription]) ON DELETE CASCADE,
    CONSTRAINT [FK_CatSubscriptionDiscountRange_ValueTypeId] FOREIGN KEY ([ValueTypeId]) REFERENCES [dbo].[CatValueType] ([IdCatValueType]) ON DELETE CASCADE
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla de tipo de valor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'ValueTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado del registro ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tabla de  catalogo de rango de descuento ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'IdCatSubscriptionDiscountRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'valor de descuento ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'DiscountValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descuento mas Alto Rango de Servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'DiscountTopServiceRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descuento mas Bajo Rango de Servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'DiscountLowServiceRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla de catalogo de subscripciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDiscountRange', @level2type = N'COLUMN', @level2name = N'CatSubscriptionId';

