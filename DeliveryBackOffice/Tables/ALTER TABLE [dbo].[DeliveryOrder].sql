/*
Script ALTER DeliveryOrder - HUBS
ALTER PARA AGREGAR IDHUBORIGEN Y IDHUBDESTINO PARA LINEHAULS
*/
​
ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder
ADD HubOriginId INT NULL;
​
ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder
ADD HubDestinationId INT NULL;