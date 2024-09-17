-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-05>
-- Description:	<Administración de lotes - Consulta de lotes>
-- =============================================

CREATE PROCEDURE [dbo].[GetBatchAdministration]
@RTN NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY

	SELECT 
		Id_Lote					AS 'IdLote'
		,RTN
		,CAI
		,LimitDateEmision		AS 'Vigente hasta'
		,Establishment			AS 'Establecimiento'
		,Emision_Point			AS 'Punto de emisión'
		,TypeDocument			AS 'Tipo de documento'
		,Status					AS 'Estado'
		,Enable					AS 'Detenido'
		,AmountGranted			AS 'Cantidad otorgada'
		,CASE 
			WHEN Last_Process > InitialRange 
			THEN (FinalRange - InitialRange) - (Last_Process - InitialRange)	
			ELSE (FinalRange - InitialRange)
		END AS 'Disponible'
	FROM DeliveryBackOffice.dbo.InvoiceBatchHeader
	WHERE RTN = @RTN OR @RTN IS NULL
		
    END TRY
    BEGIN CATCH

		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
    
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END;
