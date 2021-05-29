USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.ProductPaymentCost
   (IdProductPaymentDet bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
   ProductPaymentId bigint NOT NULL,
   CostId int NOT NULL,
	RowStatus int  NOT NULL,
	TokenCreated VARCHAR(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated VARCHAR(50) NULL,
	DateUpdated datetime NULL,
		FOREIGN KEY (ProductPaymentId) REFERENCES dbo.ProductPayment(IdProductPayment),
		FOREIGN KEY (CostId) REFERENCES dbo.Cost(IdCost),
	)
GO  

SELECT * FROM dbo.ProductPaymentCost
