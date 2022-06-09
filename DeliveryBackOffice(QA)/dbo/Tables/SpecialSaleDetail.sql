CREATE TABLE [dbo].[SpecialSaleDetail] (
    [IdSpecialSaleDetail] INT             IDENTITY (1, 1) NOT NULL,
    [SpecialSaleId]       INT             NOT NULL,
    [UnitId]              INT             NOT NULL,
    [Value]               DECIMAL (12, 2) NULL,
    [TypeDiscountId]      INT             NOT NULL,
    [RowStatus]           BIT             NOT NULL,
    [TokenCreated]        VARCHAR (50)    NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [TokenUpdated]        VARCHAR (50)    NULL,
    [DateUpdated]         DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdSpecialSaleDetail] ASC),
    CONSTRAINT [FKDiscountSale] FOREIGN KEY ([SpecialSaleId]) REFERENCES [dbo].[SpecialSale] ([IdSpecialSale]),
    CONSTRAINT [FKDiscountType] FOREIGN KEY ([TypeDiscountId]) REFERENCES [dbo].[CatTypeDiscount] ([IdCatTypeDiscount]),
    CONSTRAINT [FKDiscountUnit] FOREIGN KEY ([UnitId]) REFERENCES [dbo].[Unit] ([IdUnit])
);

