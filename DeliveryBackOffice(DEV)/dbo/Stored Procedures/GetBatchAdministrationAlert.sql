-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-05>
-- Description:	<Administración de lotes - Consulta de alertas>
-- =============================================

CREATE PROCEDURE [dbo].[GetBatchAdministrationAlert]
@RTN NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY

	SELECT 
		Id_Lote					AS 'IdLote'
		,RTN
		,CAI
		,Emision_Point			AS 'Punto de emisión'
		,Establishment			AS 'Establecimiento'
		,TypeDocument			AS 'Tipo de documento'
	FROM DeliveryBackOffice.dbo.InvoiceBatchHeader
	WHERE (RTN = @RTN OR @RTN IS NULL)
	AND DATEDIFF(day, GETDATE(), LimitDateEmision) <= DaysLeftNotifycation
	AND Status = 1
	ORDER BY LimitDateEmision ASC

    END TRY
    BEGIN CATCH

		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
    
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END;
