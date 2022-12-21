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
    PRIMARY KEY CLUSTERED ([RheId] ASC),
    FOREIGN KEY ([CountryId]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id]),
    CONSTRAINT [FK_RateHeader_CatTypeRate] FOREIGN KEY ([RateTypeId]) REFERENCES [dbo].[CatTypeRate] ([IdTypeRate])
);






GO
CREATE NONCLUSTERED INDEX [IDX_RheDefault]
    ON [dbo].[RateHeader]([RheDefault] ASC)
    INCLUDE([ReturnRate]);

