/****** Script renombrar columnas de peso volumetrico y peso masa  ******/
USE DeliveryBackOffice
EXEC sp_rename 'dbo.DeliveryOrderPiece.PiecePhysicalWeightCheck', 'volumetricWeight', 'COLUMN';
EXEC sp_rename 'dbo.DeliveryOrderPiece.PieceWeightCheck', 'MassWeight', 'COLUMN';