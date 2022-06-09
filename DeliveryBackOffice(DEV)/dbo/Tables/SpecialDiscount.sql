CREATE TABLE [dbo].[SpecialDiscount] (
    [IdSpecialDiscount]     INT             IDENTITY (1, 1) NOT NULL,
    [DiscountName]          NVARCHAR (50)   NULL,
    [PercentValue]          DECIMAL (18, 2) NULL,
    [SpecialDiscountStatus] BIT             NULL,
    [DateExpire]            DATETIME        NULL,
    [IdCustomer]            INT             NULL,
    [TokenCreated]          NVARCHAR (50)   NULL,
    [DateCreated]           DATETIME        NULL,
    [TokenUpdated]          NVARCHAR (50)   NULL,
    [DateUpdated]           DATETIME        NULL,
    CONSTRAINT [PK_SpecialDiscount] PRIMARY KEY CLUSTERED ([IdSpecialDiscount] ASC),
    CONSTRAINT [FK_SpecialDiscount_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[CustomerParser] ([IdCustomer])
);

