alter table dbo.DeliveryOrderPiece add
StatusOrderId int null
go

alter table dbo.DeliveryOrderDetail add
PieceId int null
go

ALTER TABLE dbo.DeliveryOrderDetail 
ADD FOREIGN KEY (PieceId) REFERENCES DeliveryOrderPiece(NoPiece);


ALTER TABLE dbo.DeliveryOrderPiece 
ADD FOREIGN KEY (StatusOrderId) REFERENCES StatusOrder(StatusOrderId);

update DeliveryOrderPiece set NoPiece = 1
where NoPiece is null

