/***************************************************************************************************
* TICKET:       FDAPI-5985
* DESCRIPCION:  Actualización de códigos de país nulos en Person (GT)
* AUTOR:        SYS-EGUERRA
* FECHA:        2026-03-31
* PAIS:         Guatemala (GT)
* BASE DE DATOS: DeliveryBackOffice
*
* TABLAS AFECTADAS:
*   - Person
*
* NOTA:
*   - El script incluye transacción automática con ROLLBACK en caso de error
***************************************************************************************************/

BEGIN TRY
	BEGIN TRANSACTION;

	USE DeliveryBackOffice;
	UPDATE Person
		SET [PerCountryOrigin] = 'GT'
		WHERE [PerCountryOrigin] IS NULL;
	PRINT 'Cambios aplicados permanentemente.';
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Error detectado - Los cambios han sido rechazados.';
END CATCH;

GO
