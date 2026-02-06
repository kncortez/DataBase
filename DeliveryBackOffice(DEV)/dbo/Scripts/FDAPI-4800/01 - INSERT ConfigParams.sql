BEGIN TRY
BEGIN TRANSACTION

	INSERT INTO ConfigParams
	(
		Name,
		Description,
		Value,
		Status,
		CreateDate,
		IdCountry,
		IdCurrencyCOD
	)
	VALUES
	(
		'PathDeliveryVoucherDetail',
		'Carpeta para Almacenar los detalles de los comprobantes de entrega digitales.',
		'https://sandbox.apicore.forzadelivery.io:40467/comprobantes/Detalles/',
		1  ,
		GETDATE(),
		'GT',
		NULL
	)
    COMMIT TRANSACTION
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH