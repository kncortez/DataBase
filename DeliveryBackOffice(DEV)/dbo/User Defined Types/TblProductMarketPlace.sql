CREATE TYPE [dbo].[TblProductMarketPlace] AS TABLE (
    [IsGift]                   BIT            NOT NULL,
    [ProductGiftShippingEmail] NVARCHAR (100) NOT NULL,
    [IdCatProduct]             INT            NOT NULL);

