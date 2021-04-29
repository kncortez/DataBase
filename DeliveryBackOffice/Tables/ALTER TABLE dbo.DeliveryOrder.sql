


ALTER TABLE dbo.DeliveryOrder
add ReceiverIdSettlement bigint null;

Alter Table dbo.DeliveryOrder
ADD FOREIGN KEY(ReceiverIdSettlement) REFERENCES dbo.Settlement(IdSettlement)

select  top 1 * from dbo.DeliveryOrder
