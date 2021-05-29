USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.ProductPaymentDetail  
   (IdProductPaymentDet bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
   ProductPaymentId bigint NOT NULL,
   TypeOfMoneyId int NOT NULL,
	Amount decimal(12,2) NOT NULL,
	Voucher VARCHAR(200) NULL,
	RowStatus int  NOT NULL,
	TokenCreated VARCHAR(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated VARCHAR(50) NULL,
	DateUpdated datetime NULL,
		FOREIGN KEY (ProductPaymentId) REFERENCES dbo.ProductPayment(IdProductPayment),
		FOREIGN KEY (TypeOfMoneyId) REFERENCES dbo.ctgTypeOfInOutOfMoney(tio_pk_id)
	)
GO  

SELECT * FROM dbo.ProductPaymentDetail




