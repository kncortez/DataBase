ALTER TABLE [DeliveryBackOffice].[dbo].[Customer] ADD COD BIT NULL

ALTER TABLE [DeliveryBackOffice].[dbo].[VisitPointClient] ADD CONSTRAINT U_CodeOfReference UNIQUE(CodeOfReference)