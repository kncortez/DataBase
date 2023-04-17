CREATE TABLE [dbo].[PackagesRange] (
    [IdPackagesRange]      INT             IDENTITY (1, 1) NOT NULL,
    [Range]                NVARCHAR (50)   NOT NULL,
    [DiscountPercentage]   DECIMAL (18, 2) NOT NULL,
    [Order]                INT             NOT NULL,
    [CatBusinessSegmentId] INT             NOT NULL,
    [CatTypeRateId]        INT             NOT NULL,
    [IsPercent]            BIT             CONSTRAINT [DF_PackagesRange_IsPercent] DEFAULT ((0)) NOT NULL,
    [WeightLimit]          DECIMAL (12, 2) NULL,
    [AdditionalWeightRate] DECIMAL (12, 2) NULL,
    [InsuranceRate]        DECIMAL (12, 2) NULL,
    [InsuranceExempt]      DECIMAL (12, 2) NULL,
    [CreditCardRate]       DECIMAL (12, 2) NULL,
    [ReturnRate]           DECIMAL (12, 2) NULL,
    [FragilRate]           DECIMAL (12, 2) NULL,
    [CollectRate]          DECIMAL (12, 2) NULL,
    [Attempt]              INT             NULL,
    [PiecesIncluded]       DECIMAL (12, 2) NULL,
    [RowStatus]            BIT             CONSTRAINT [DF_PackagesRange_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]         NVARCHAR (50)   NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [TokenUpdated]         NVARCHAR (50)   NULL,
    [DateUpdated]          DATETIME        NULL,
    CONSTRAINT [PK_PackagesRange] PRIMARY KEY CLUSTERED ([IdPackagesRange] ASC),
    CONSTRAINT [FK_PackagesRange_CatBusinessSegment] FOREIGN KEY ([CatBusinessSegmentId]) REFERENCES [dbo].[CatBusinessSegment] ([IdBusinessSegment]),
    CONSTRAINT [FK_PackagesRange_CatTypeRate] FOREIGN KEY ([CatTypeRateId]) REFERENCES [dbo].[CatTypeRate] ([IdTypeRate])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Toquen de modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Segmento del negocio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'CatBusinessSegmentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden del rango', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'Order';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'DiscountPercentage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rango de paquetes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'Range';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los rango de paquetes para las tarifas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de tarifa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'CatTypeRateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso base incluído', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'WeightLimit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tarifa base devolución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'ReturnRate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Piezas incluidas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'PiecesIncluded';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Especificar si es un valor o un porcentaje', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'IsPercent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cobro por Ad Valorem Seguro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'InsuranceRate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Seguro exento hasta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'InsuranceExempt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Recargo por paquete frágil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'FragilRate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Recargo por tarjeta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'CreditCardRate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cobro en destino (Collect)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'CollectRate';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Intentos de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'Attempt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio por libra adicional', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRange', @level2type = N'COLUMN', @level2name = N'AdditionalWeightRate';

