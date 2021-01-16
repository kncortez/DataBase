USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.RegisterUser  
   (UsrIdUser bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	UsrIdPerson bigint NOT NULL,
	UsrNickName varchar(100) NOT NULL,
	UsrEmail varchar(200) NOT  NULL,
	UsrAvatar  varchar(200)   NULL,
	UsrLastPassword varchar(200) NOT NULL,
	UsrPasswordExpiration DATE NOT NULL,
	UsrLang  varchar(2)   NULL,
	UsrDeviceType  varchar(50)   NULL,
	UsrCurrency  varchar(10)   NULL,
	UsrEnable2FA bit  NULL,
	UsrRestrictionAddressIp varchar(200)  NULL,
	UsrRowStatus bit NOT NULL,
	UsrTokenCreated varchar(50)  NOT NULL,
	UsrDateCreated datetime  NOT NULL,
	UsrTokenUpdated varchar(50)   NULL,
	UsrDateUpdated datetime   NULL,
	CONSTRAINT Uk_Email UNIQUE (UsrEmail),
	FOREIGN KEY (UsrIdPerson) REFERENCES Person(PerIdPerson)
	)
GO  
/*
insert into  DeliveryBackOffice.dbo.RegisterUser  
	(UsrIdPerson
	,UsrNickName
	,UsrEmail
	,UsrAvatar
	,UsrLastPassword
	,UsrPasswordExpiration
	,UsrLang
	,UsrDeviceType
	,UsrCurrency
	,UsrEnable2FA
	,UsrRestrictionAddressIp
	,UsrRowStatus
	,UsrTokenCreated
	,UsrDateCreated
	)
Values(1,'caquino','caquino@forzalatam.com',null,'12345','2021-12-21','ES','Web','QTZ',null,null, 1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.RegisterUser */
