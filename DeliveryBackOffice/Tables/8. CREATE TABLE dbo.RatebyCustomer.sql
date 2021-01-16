USE [DeliveryBackOffice]
GO
 
CREATE TABLE DeliveryBackOffice.dbo.RatebyCustomer
   (RbcId bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	RbcIdRate int NOT NULL,
	RbcIdCustomer int NOT NULL,
	RbcRowStatus bit NOT NULL,
	RbcTokenCreated varchar(50)  NOT NULL,
	RbcDateCreated datetime  NOT NULL,
	RbcTokenUpdated varchar(50)   NULL,
	RbcDateUpdated datetime   NULL,
	COnSTRAINT FKRbcRate FOREIGN KEY (RbcIdRate) REFERENCES RateHeader(RheId),
	CONSTRAINT FKRbcCustomer FOREIGN KEY (RbcIdCustomer) REFERENCES Customer(IdCustomer)
	)

GO  

insert into DeliveryBackOffice.dbo.RatebyCustomer  
	(RbcIdRate
	,RbcIdCustomer
	,RbcRowStatus
	,RbcTokenCreated
	,RbcDateCreated
	)
Values(1,6,1,'SYS-CAQUINO',GETDATE()),
	(2,24,1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.RatebyCustomer  