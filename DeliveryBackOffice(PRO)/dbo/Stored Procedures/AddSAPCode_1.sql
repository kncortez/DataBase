Create procedure AddSAPCode (@SAPCode nvarchar(12) , @ordernumber int) 
as
Begin

UPDATE DeliveryBackOffice.dbo.invoiceDetail SET SAPCode = @SAPCode
WHERE dti_fk_orderNumber = @ordernumber and SAPCode IS NULL

end