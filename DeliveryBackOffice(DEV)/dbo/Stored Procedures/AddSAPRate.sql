Create procedure AddSAPRate (@list nvarchar(200)) 
as
Begin
declare @delimeter nvarchar(2) = ','
UPDATE DeliveryBackOffice.dbo.InvoiceRestriction
SET invRetries = 0
WHERE inv_pk_id IN (select Item from deliverybackoffice.dbo.SplitUnlimited (@list,@delimeter))

end