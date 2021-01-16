USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.BillingProfile
   (BlpIdBilling bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	BlpIdAccount bigint NOT NULL,
	BlpName varchar(100) NOT NULL,
	BlpAddress varchar(200) NOT NULL,
	BlpTaxId varchar(50)  NULL,
	BlpRowStatus bit NOT NULL,
	BlpTokenCreated varchar(50)  NOT NULL,
	BlpDateCreated datetime  NOT NULL,
	BlpTokenUpdated varchar(50)   NULL,
	BlpDateUpdated datetime   NULL,
	CONSTRAINT FKBillingAccount FOREIGN KEY (BlpIdAccount) REFERENCES Account(AccIdAccount)
	)
GO  