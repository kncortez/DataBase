
IF NOT EXISTS (
	SELECT
		1
	FROM
		[DeliveryBackOffice].[dbo].[StatusOrder] SO
	WHERE
		SO.OrderDescription = 'Paquete destruido'
)
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[StatusOrder] (OrderDescription)
	VALUES ('Paquete destruido');
END