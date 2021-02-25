USE [DeliveryBackOffice]
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] ADD NoPiece int
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] ADD PieceHeightCheck decimal(12,2)
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] ADD PieceWidthCheck decimal(12,2)
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] ADD PieceLengthCheck decimal(12,2)
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] ADD PieceWeightCheck decimal(12,2)
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] ADD PiecePhysicalWeightCheck decimal(12,2)