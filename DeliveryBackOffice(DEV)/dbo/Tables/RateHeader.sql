CREATE TABLE [dbo].[RateHeader] (
    [RheId]                INT             IDENTITY (1, 1) NOT NULL,
    [RheName]              VARCHAR (200)   NOT NULL,
    [RheShortName]         VARCHAR (3)     NOT NULL,
    [RheDescription]       VARCHAR (200)   NULL,
    [RheDefault]           BIT             NOT NULL,
    [RheRowStatus]         BIT             NOT NULL,
    [RheTokenCreated]      VARCHAR (50)    NOT NULL,
    [RheDateCreated]       DATETIME        NOT NULL,
    [RheTokenUpdated]      VARCHAR (50)    NULL,
    [RheCreateUpdated]     DATETIME        NULL,
    [RateTypeId]           INT             NULL,
    [FragilRate]           DECIMAL (12, 2) NULL,
    [InsuranceRate]        DECIMAL (12, 2) NULL,
    [InsuranceExempt]      DECIMAL (12, 2) NULL,
    [AdditionalWeightRate] DECIMAL (12, 2) NULL,
    [WeightLimit]          DECIMAL (12, 2) NULL,
    [CreditCardRate]       DECIMAL (12, 2) NULL,
    [PickupRate]           DECIMAL (12, 2) NULL,
    [Attempt]              INT             NULL,
    [CountryId]            VARCHAR (2)     NULL,
    [CurrencyId]           INT             NULL,
    [IsTemplate]           BIT             NULL,
    [RateByPiece]          BIT             NULL,
    [ReturnRate]           DECIMAL (12, 2) NULL,
    [CollectRate]          DECIMAL (12, 2) NULL,
    [PiecesIncluded]       DECIMAL (12, 2) NULL,
    [AttemptReturn]        INT             CONSTRAINT [DF__RateHeade__Attem__6423B28F] DEFAULT ((2)) NOT NULL,
    [CutOffDate]           TINYINT         NULL,
    [CatBusinessSegmentId] INT             NULL,
    [PackagesRangeId]      INT             NULL,
    PRIMARY KEY CLUSTERED ([RheId] ASC),
    FOREIGN KEY ([CountryId]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id]),
    CONSTRAINT [FK_RateHeader_CatBusinessSegment] FOREIGN KEY ([CatBusinessSegmentId]) REFERENCES [dbo].[CatBusinessSegment] ([IdBusinessSegment]),
    CONSTRAINT [FK_RateHeader_CatTypeRate] FOREIGN KEY ([RateTypeId]) REFERENCES [dbo].[CatTypeRate] ([IdTypeRate])
);








GO
CREATE NONCLUSTERED INDEX [IDX_RheDefault]
    ON [dbo].[RateHeader]([RheDefault] ASC)
    INCLUDE([ReturnRate]);


GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre corto del tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheShortName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheDescription'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tarifario por defecto con el valor 1 el resto con 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheDefault'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'1 activo, 0 inactivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheRowStatus'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheTokenCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheDateCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheTokenUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RheCreateUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de tarifario al que pertenece' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RateTypeId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de la tarifa fragil' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'FragilRate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Valor del seguro de tarifa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'InsuranceRate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Seguro exento hasta de la tarifa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'InsuranceExempt'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Peso adicional de tarifa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'AdditionalWeightRate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Peso limite de la tarifa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'WeightLimit'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Recargo por tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'CreditCardRate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tarifa de recoger' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'PickupRate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Intentos de entrega' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'Attempt'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del país al que pertenece el tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'CountryId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de moneda del tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'CurrencyId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Es plantilla el tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'IsTemplate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tarifa por pieza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'RateByPiece'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Retorno de tarifa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'ReturnRate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Cobro en destino collect' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'CollectRate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de piezas incluidas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'PiecesIncluded'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Número de intentos disponibles para devolución.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'AttemptReturn'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de corte para tarifario por paquetes 1=Inicio de mes, 2=Quincena, 3=Fin de mes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'CutOffDate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Segmento de negocio al que pertenece.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'CatBusinessSegmentId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Rango de paquetes al que pertenece.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader', @level2type=N'COLUMN',@level2name=N'PackagesRangeId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que contiene la informacion de los tarifarios' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateHeader'
GO