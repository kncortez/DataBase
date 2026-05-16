/***************************************************************************************************
* TICKET:       FDAPI-5985
* DESCRIPCION:  Creación de índice en DeliveryOrder para optimización de consultas sobre StatusOrderId y DateCreated
* AUTOR:        SYS-EGUERRA
* FECHA:        2026-04-07
* PAIS:         Guatemala (GT)
* BASE DE DATOS: DeliveryBackOffice
*
* TABLAS AFECTADAS:
*   - DeliveryOrder
*
* NOTA:
*   - El script incluye transacción automática con ROLLBACK en caso de error
***************************************************************************************************/

BEGIN TRY
	BEGIN TRANSACTION;

	USE [DeliveryBackOffice]
	CREATE NONCLUSTERED INDEX [IDX_StatusOrderId_DateCreated_INCLUDE]
	ON [dbo].[DeliveryOrder] ([StatusOrderId],[DateCreated])
	INCLUDE ([IdCustomer])
	PRINT 'Cambios aplicados permanentemente.';
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Error detectado - Los cambios han sido rechazados.';
END CATCH;

GO
