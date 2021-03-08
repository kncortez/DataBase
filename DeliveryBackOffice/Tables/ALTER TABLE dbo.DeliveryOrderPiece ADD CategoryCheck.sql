USE [DeliveryBackOffice]
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] ADD CategoryCheck int

ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] ADD CONSTRAINT FK_CategoryCheck
FOREIGN KEY(CategoryCheck) REFERENCES DeliveryBackOffice.dbo.CatArticle(ArtId)