USE [DeliveryBackOffice]
GO
 
CREATE TABLE DeliveryBackOffice.dbo.CatTypeDiscount
   (IdCatTypeDiscount int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name varchar(50) NOT NULL,
	ShortName varchar(10) not null,
	Description varchar(100)  NULL,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)
GO  

insert into DeliveryBackOffice.dbo.CatTypeDiscount  
	(Name
	,ShortName
	,Description
	,RowStatus
	,TokenCreated
	,DateCreated)
Values('Base','BSD', 'Cálculo en función de la tarifa base',1,'SYS-CAQUINO',GETDATE())
,('Total','TOT', 'Cálculo en función de el total del envío',1,'SYS-CAQUINO',GETDATE())



select * from DeliveryBackOffice.dbo.CatTypeDiscount  