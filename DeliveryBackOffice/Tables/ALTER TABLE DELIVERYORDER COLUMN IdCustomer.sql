ALTER TABLE DeliveryBackOffice.dbo.[DeliveryOrder]
	ADD IdCustomer int; 
	go
	alter table DeliveryBackOffice.[dbo].[DeliveryOrder]
add IndicationsToSendOrigin varchar(1500);
go
alter table DeliveryBackOffice.[dbo].[DeliveryOrder]
add IndicationsToSendDestination varchar(1500);
go
alter table DeliveryBackOffice.dbo.DeliveryOrder
add IsInsuarance bit  
go	
	