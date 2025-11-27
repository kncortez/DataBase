BEGIN TRY
    BEGIN TRANSACTION;

	WHILE 1 = 1
	BEGIN
		UPDATE TOP (10000) invoiceHeader
		SET IdCountry = 'GT'
		WHERE IdCountry IS NULL;

		IF @@ROWCOUNT = 0 BREAK;
	END

    COMMIT TRANSACTION;
    PRINT 'Actualización completada exitosamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;
