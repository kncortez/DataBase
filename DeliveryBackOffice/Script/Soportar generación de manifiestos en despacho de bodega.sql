USE DeliveryBackOffice;

-- ALTER TABLE DeliveryAttempt DROP CONSTRAINT [FK_DeliveryAttempt_DeliveryOrderBySettlement]

ALTER TABLE DeliveryAttempt ADD CONSTRAINT [FK_DeliveryAttempt_DeliveryOrderBySettlement] FOREIGN KEY ([ID_DeliveryOrderBySettlement])
REFERENCES DeliveryOrderBySettlement ([ID])

--ALTER TABLE DeliveryOrderBySettlement DROP CONSTRAINT PK_DeliveryOrderBySettlement
--ALTER TABLE DeliveryOrderBySettlement DROP CONSTRAINT [pk_primary_key_DeliveryOrderBySettlement]
--ALTER TABLE DeliveryOrderBySettlement DROP COLUMN Serie

--ALTER TABLE DeliveryOrderBySettlement ADD Serie NVARCHAR(2) NOT NULL
/*ALTER TABLE DeliveryOrderBySettlement ADD CONSTRAINT PK_DeliveryOrderBySettlement PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)*/

ALTER TABLE DeliveryOrderBySettlement ADD CONSTRAINT FK_DeliveryOrderSettlement_SenderReceiver FOREIGN KEY (ID_Courier)
REFERENCES SenderReceiver(ID)

ALTER TABLE DeliveryOrderBySettlement ADD Route_Dispatched datetime NULL
ALTER TABLE DeliveryOrderBySettlement ADD Route_Received datetime NULL