USE [DeliveryBackOffice]
GO
CREATE NONCLUSTERED INDEX [IDX_StationDispatchedId_CatRouteId_INCLUDE]
ON [dbo].[LinehaulRoutePreparation] ([StationDispatchedId],[CatRouteId])
INCLUDE ([DateLinehaulRoutePreparation])
GO