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
    [CutOffDate]           TINYINT         NULL,
    [CatBusinessSegmentId] INT             NULL,
    [PackagesRangeId]      INT             NULL,
    PRIMARY KEY CLUSTERED ([RheId] ASC),
    FOREIGN KEY ([CountryId]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id]),
    CONSTRAINT [FK_RateHeader_CatBusinessSegment] FOREIGN KEY ([CatBusinessSegmentId]) REFERENCES [dbo].[CatBusinessSegment] ([IdBusinessSegment]),
    CONSTRAINT [FK_RateHeader_CatTypeRate] FOREIGN KEY ([RateTypeId]) REFERENCES [dbo].[CatTypeRate] ([IdTypeRate]),
    CONSTRAINT [FK_RateHeader_PackagesRange] FOREIGN KEY ([PackagesRangeId]) REFERENCES [dbo].[PackagesRange] ([IdPackagesRange])
);








GO
CREATE NONCLUSTERED INDEX [IDX_RheDefault]
    ON [dbo].[RateHeader]([RheDefault] ASC)
    INCLUDE([ReturnRate]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de corte para tarifario por paquetes 1=Inicio de mes, 2=Quincena, 3=Fin de mes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateHeader', @level2type = N'COLUMN', @level2name = N'CutOffDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rango de paquetes al que pertenece.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateHeader', @level2type = N'COLUMN', @level2name = N'PackagesRangeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Segmento de negocio al que pertenece.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateHeader', @level2type = N'COLUMN', @level2name = N'CatBusinessSegmentId';

