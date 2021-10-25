
  ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]
  ADD DispatchedStationId INT NULL;

  ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]
  ADD SettlementStationId INT NULL;

  EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la estación donde se realizo el despacho' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderBySettlement', @level2type=N'COLUMN',@level2name=N'DispatchedStationId'
  GO

  EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la estación donde se realizo la liquidación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderBySettlement', @level2type=N'COLUMN',@level2name=N'SettlementStationId'
  GO

  ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]
  ADD CONSTRAINT FK_DeliveryOrderBySettlement_CatStationDispatch FOREIGN KEY (DispatchedStationId) REFERENCES [DeliveryBackOffice].[dbo].[CatStation](IdStation);

  ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]
  ADD CONSTRAINT FK_DeliveryOrderBySettlement_CatStationSettlement FOREIGN KEY (SettlementStationId) REFERENCES [DeliveryBackOffice].[dbo].[CatStation](IdStation);
  
/*
	alter table [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] drop constraint FK_DeliveryOrderBySettlement_CatStationDispatch
	go

	alter table [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] drop column DispatchedStationId

	alter table [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] drop constraint FK_DeliveryOrderBySettlement_CatStationSettlement
	go

	alter table [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] drop column SettlementStationId
*/