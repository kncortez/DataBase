USE DeliveryBackOffice
GO
IF (select ISNULL(c.COLUMN_NAME,'')
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE COLUMN_NAME = 'systemOperation' AND TABLE_NAME = 'invoiceHeader') <> ''
BEGIN
	ALTER TABLE DeliveryBackOffice.[dbo].[invoiceHeader]
	ADD systemOperation int; 
END 