CREATE TYPE [dbo].[TblProductMarketPlace2] AS TABLE (
    [IsGift]                   BIT            NOT NULL,
    [ProductGiftShippingEmail] NVARCHAR (100) NOT NULL,
    [IdCatProduct]             INT            NOT NULL,
    [TypeSalePackage]          NVARCHAR (25)  NOT NULL);

