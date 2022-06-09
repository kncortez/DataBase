CREATE TABLE [dbo].[SpecialSaleTarget] (
    [IdSpecialSaleTarget] INT          IDENTITY (1, 1) NOT NULL,
    [SpecialSaleId]       INT          NOT NULL,
    [SalesPipeLineId]     INT          NULL,
    [CustomerTypeid]      INT          NULL,
    [CustomerId]          INT          NULL,
    [TypeServiceId]       INT          NULL,
    [TypeProductId]       INT          NULL,
    [RowStatus]           BIT          NOT NULL,
    [TokenCreated]        VARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME     NOT NULL,
    [TokenUpdated]        VARCHAR (50) NULL,
    [DateUpdated]         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdSpecialSaleTarget] ASC),
    CONSTRAINT [FKTargetCustomer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FKTargetCustomerType] FOREIGN KEY ([CustomerTypeid]) REFERENCES [dbo].[CustomerType] ([IdCustomerType]),
    CONSTRAINT [FKTargetPipe] FOREIGN KEY ([SalesPipeLineId]) REFERENCES [dbo].[CatSalePipelines] ([IdSalePipeLine]),
    CONSTRAINT [FKTargetProduct] FOREIGN KEY ([TypeProductId]) REFERENCES [dbo].[CatTypeProduct] ([IdTypeProduct]),
    CONSTRAINT [FKTargetSale] FOREIGN KEY ([SpecialSaleId]) REFERENCES [dbo].[SpecialSale] ([IdSpecialSale]),
    CONSTRAINT [FKTargetTypeService] FOREIGN KEY ([TypeServiceId]) REFERENCES [dbo].[CatTypeService] ([CtsId])
);

