USE DeliveryBackOffice
GO
ALTER TABLE dbo.LogTokenPOD ADD
RowStatus bit NULL,
DateCreated datetime null,
DateUpdate datetime null
go