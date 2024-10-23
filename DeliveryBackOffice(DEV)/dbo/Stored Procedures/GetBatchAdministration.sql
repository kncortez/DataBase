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
		IBH.Id_Lote					AS 'IdLote'
		,IBH.RTN
		,IBH.CAI
		,IBH.LimitDateEmision		AS 'Vigente hasta'
		,IBH.Establishment			AS 'Establecimiento'
		,IBH.Emision_Point			AS 'Punto de emisión'
		,IBH.TypeDocument			AS 'Tipo de documento'
		,ISNULL(CTD.Name,'')		AS 'Nombre de tipo de documento'
		,IBH.Status					AS 'Estado'
		,IBH.Enable					AS 'Detenido'
		,IBH.AmountGranted			AS 'Cantidad otorgada'
		,CASE 
			WHEN IBH.Last_Process > IBH.InitialRange 
			THEN (IBH.FinalRange - IBH.InitialRange) - (IBH.Last_Process - IBH.InitialRange)	
			ELSE (IBH.FinalRange - IBH.InitialRange)
		END AS 'Disponible'
	FROM DeliveryBackOffice.dbo.InvoiceBatchHeader IBH WITH(NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.CatTypeDocument CTD WITH(NOLOCK)
		ON IBH.TypeDocument = CTD.IdTypeDocument
	WHERE IBH.RTN = @RTN OR @RTN IS NULL
		
    END TRY
    BEGIN CATCH

		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
    
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END;
