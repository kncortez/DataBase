update DeliveryBackOffice.dbo.Customer
set Name = 'UNIVERSAL DE MOTOS'
,Description = 'UNIVERSAL DE MOTOS'
where IdCustomer = 310

update DeliveryBackOffice.dbo.VisitPointClient
set DescriptionOfClient = 'UNIVERSAL DE MOTOS'
where CustomerID = 310 and CodeOfReference = 14850