USE DeliveryBackOffice
GO
ALTER TABLE dbo.DeliveryProof ADD
	  CollectOnDelivery decimal(18,2)NULL,
	  Collect decimal(18,2)NULL,
      PayCash decimal(18,2)NULL,
      PayTarjet decimal(18,2)NULL,
      TicketPOS nvarchar(50)NULL,
      Autoritations nvarchar(50)NULL,
      TotalPay decimal(18,2)NULL,
      IsDelivery int NULL
