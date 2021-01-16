USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.Person  
   (PerIdPerson bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	PerFirstName varchar(100) NOT NULL,
	PerLastName varchar(100) NOT NULL,
	PerGender varchar(2)  NULL,
	PerBirthdate date  NULL,
	PerIdentification varchar(50) NOT NULL,
	PerNationality varchar(100) NOT NULL,
	PerRowStatus bit NOT NULL,
	PerTokenCreated varchar(50)  NOT NULL,
	PerDateCreated datetime  NOT NULL,
	PerTokenUpdated varchar(50)   NULL,
	PerDateUpdated datetime   NULL
	CONSTRAINT Uk_Person UNIQUE (PerIdentification)
	)
GO  
/*
insert into DeliveryBackOffice.dbo.Person  
	(PerFirstName
	,PerLastName
	,PerGender
	,PerBirthdate
	,PerIdentification
	,PerNationality
	,PerRowStatus
	,PerTokenCreated
	,PerDateCreated)
Values('César','Aquino', 'M',getdate(),'090106396', 'guatemalteco', 1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.Person 
*/