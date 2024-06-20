CREATE TABLE [dbo].[TEMP_Rate_TST] (
    [TypeRate]           VARCHAR (50)    NULL,
    [Segment]            VARCHAR (50)    NULL,
    [Service]            VARCHAR (50)    NULL,
    [Price]              DECIMAL (12, 2) NULL,
    [BaseRate]           DECIMAL (12, 2) NULL,
    [Discount]           DECIMAL (12, 2) NULL,
    [DiscountName]       VARCHAR (100)   NULL,
    [FragilRate]         DECIMAL (12, 2) NULL,
    [CollectedRate]      DECIMAL (12, 2) NULL,
    [InsuranceRate]      DECIMAL (12, 2) NULL,
    [OverWeightRate]     DECIMAL (12, 2) NULL,
    [IrregularPieceRate] DECIMAL (12, 2) NULL,
    [CreditCardRate]     DECIMAL (12, 2) NULL,
    [Taxes]              DECIMAL (12, 2) NULL,
    [FechaCompra]        DATETIME        NULL,
    [Currency]           VARCHAR (10)    NULL,
    [ReturnRate]         DECIMAL (12, 2) NULL,
    [RevaluedGuideflag]  BIT             NULL
);

