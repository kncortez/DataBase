USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.ProductPayment  
   (IdProductPayment bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Amount decimal(12,2) NOT NULL,
	DatePayment datetime NOT NULL,
	ModuleId int   NULL,
	Responsible VARCHAR(200) NULL,
	Observation VARCHAR(500) NULL,
	RowStatus int  NOT NULL,
	TokenCreated VARCHAR(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated VARCHAR(50) NULL,
	DateUpdated datetime NULL
	)
GO  

SELECT * FROM dbo.ProductPayment

