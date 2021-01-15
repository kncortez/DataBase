USE DeliveryBackOffice;

ALTER TABLE DeliveryOrderBySettlement ADD ID_HubLogistic INT NULL
ALTER TABLE DeliveryOrderBySettlement ADD CONSTRAINT [FK_DeliveryOrderSettlement_HubLogistics] FOREIGN KEY([ID_HubLogistic]) REFERENCES HubLogistics ([IdHubLogistic])