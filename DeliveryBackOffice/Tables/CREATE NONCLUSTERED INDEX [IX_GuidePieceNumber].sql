/*
Missing Index Details from PRUEBAS OPTIMIZACIÓN.sql - 192.168.31.57.DeliveryBackOffice (mjimenez (59))
The Query Processor estimates that implementing the following index could improve the query cost by 71.7961%.
*/


USE [DeliveryBackOffice]
GO
CREATE NONCLUSTERED INDEX [IX_GuidePieceNumber]
ON [dbo].[DeliveryOrderPiece] ([GuidePiece])
INCLUDE ([GuideNumber])
GO

