/***************************************************************************************************
* TICKET:       FDAPI-5985
* DESCRIPCION:  Creación de índice en Customer para optimización de consultas sobre CatTMSalesPersonId y CutOffDate
* AUTOR:        SYS-EGUERRA
* FECHA:        2026-04-07
* PAIS:         Guatemala (GT)
* BASE DE DATOS: DeliveryBackOffice
*
* TABLAS AFECTADAS:
*   - Customer
*
* NOTA:
*   - El script incluye transacción automática con ROLLBACK en caso de error
***************************************************************************************************/

BEGIN TRY
	BEGIN TRANSACTION;

	USE [DeliveryBackOffice]
	CREATE NONCLUSTERED INDEX [IDX_Customer_CatTMSalesPersonId_CutOffDate_INCLUDE]
	ON [dbo].[Customer] (CatTMSalesPersonId, CutOffDate)
	INCLUDE (CustomerGoalQuantity,IdCustomer)
	PRINT 'Cambios aplicados permanentemente.';
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Error detectado - Los cambios han sido rechazados.';
END CATCH;

GO
