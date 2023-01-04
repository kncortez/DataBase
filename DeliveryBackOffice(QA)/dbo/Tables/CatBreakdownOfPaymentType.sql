CREATE TABLE [dbo].[CatBreakdownOfPaymentType] (
    [IdCatBreakdownOfPaymentType]       INT            IDENTITY (1, 1) NOT NULL,
    [BreakdownOfPaymentTypeName]        NVARCHAR (200) NOT NULL,
    [BreakdownOfPaymentTypeDescription] NVARCHAR (600) NULL,
    [RowStatus]                         BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]                       DATETIME       NOT NULL,
    [TokenCreated]                      NVARCHAR (50)  NOT NULL,
    [DateUpdated]                       DATETIME       NULL,
    [TokenUpdated]                      NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatBreakdownOfPaymentType] ASC)
);

