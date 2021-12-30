ALTER TABLE DeliveryBackOffice.[dbo].[DeliveryOrderBySettlement]
ADD CatVehicleId [int] null

ALTER TABLE DeliveryBackOffice.[dbo].[DeliveryOrderBySettlement]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrderBySettlement_CatVehicleId] FOREIGN KEY([CatVehicleId])
REFERENCES DeliveryBackOffice.[dbo].[CatVehicle] ([IdVehicle])

ALTER TABLE DeliveryBackOffice.[dbo].[DeliveryOrderBySettlement] CHECK CONSTRAINT [FK_DeliveryOrderBySettlement_CatVehicleId]
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Id del Vehículo en la tabla CatVehicle', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrderBySettlement', N'COLUMN', N'CatVehicleId'


ALTER TABLE DeliveryBackOffice.[dbo].[DeliveryOrderBySettlement]
ADD CatRouteId [int] null

ALTER TABLE DeliveryBackOffice.[dbo].[DeliveryOrderBySettlement]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrderBySettlement_CatRouteId] FOREIGN KEY([CatRouteId])
REFERENCES DeliveryBackOffice.[dbo].[CatRoute] ([IdRoute])

ALTER TABLE DeliveryBackOffice.[dbo].[DeliveryOrderBySettlement] CHECK CONSTRAINT [FK_DeliveryOrderBySettlement_CatRouteId]
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Id de la ruta en la tabla CatRoute', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrderBySettlement', N'COLUMN', N'CatRouteId'


ALTER TABLE DeliveryBackOffice.[dbo].[DeliveryOrderBySettlement]
ADD StartingKilometers [nvarchar](50) null

EXECUTE sp_addextendedproperty N'MS_Description', N'Kilómetros que tiene el Vehículo', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrderBySettlement', N'COLUMN', N'StartingKilometers'
