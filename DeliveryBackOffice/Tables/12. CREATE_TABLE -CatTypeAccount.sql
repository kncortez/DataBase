USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatTypeAccount  
   (TacIdTypeAccount int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	TacShortName varchar(3) NOT NULL,
	TacName varchar(30) NOT NULL,
	TacDescription varchar(100) NOT NULL,
	TacRowStatus bit NOT NULL,
	TacTokenCreated varchar(50)  NOT NULL,
	TacDateCreated date  NOT NULL,
	TacTokenUpdated varchar(50)   NULL,
	TacDateUpdated date   NULL)
GO  
/*
insert into DeliveryBackOffice.dbo.CatTypeAccount  
	(TacShortName
	,TacName
	,TacDescription
	,TacRowStatus
	,TacTokenCreated
	,TacDateCreated)
Values('IND','Individual', 'Cuentas individuales',1,'SYS-DEVELOP',GETDATE()),
		('FAM','Familiar', 'Cuenta para compartir en familia',1,'SYS-DEVELOP',GETDATE()),
		('ESC','Escolar', 'Cuenta para grupos escolares',1,'SYS-DEVELOP',GETDATE())

select * from DeliveryBackOffice.dbo.CatTypeAccount  

*/