ALTER TABLE [dbo].[SellerDepot]
DROP CONSTRAINT [SellerDepot_UK];

ALTER TABLE [dbo].[SellerDepot]
ADD CONSTRAINT [SellerDepot_UK] UNIQUE (IdSeller, CodeOfReference);   