CREATE TABLE [dbo].[FlateRate] (
    [IdRate]               INT             IDENTITY (1, 1) NOT NULL,
    [IdDimensional]        INT             NULL,
    [IdSegmentArea]        INT             NULL,
    [ExceededRate]         BIT             NULL,
    [PriceRate]            DECIMAL (18, 2) NULL,
    [AdicionalCostPerUnit] DECIMAL (18, 2) NULL,
    [IdCurrency]           INT             NULL,
    [IdCountry]            NVARCHAR (2)    NULL,
    [FlatRateStatus]       BIT             NULL,
    [IdRateCategory]       INT             NULL,
    [DateFromValid]        DATETIME        NULL,
    [DateExpired]          DATETIME        NULL,
    [TokenCreated]         NVARCHAR (50)   NULL,
    [DateCreated]          DATETIME        NULL,
    [TokenUpdated]         NVARCHAR (50)   NULL,
    [DateUpdated]          DATETIME        NULL,
    CONSTRAINT [PK_FlateRate] PRIMARY KEY CLUSTERED ([IdRate] ASC),
    CONSTRAINT [FK_FlateRate_Dimensional] FOREIGN KEY ([IdDimensional]) REFERENCES [dbo].[DimensionalParameter] ([IdDimensional]),
    CONSTRAINT [FK_FlateRate_RateCategory] FOREIGN KEY ([IdRateCategory]) REFERENCES [dbo].[RateCategory] ([IdRateCategory]),
    CONSTRAINT [FK_FlateRate_SegmentArea] FOREIGN KEY ([IdSegmentArea]) REFERENCES [dbo].[SegmentArea] ([IdSegmentArea])
);

