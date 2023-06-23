-- =============================================
-- Author:		<Oscar Moraless>
-- Create date: <2023-06-19>
-- Description:	<Obtiene información de las rutas en procesos especiales dependiendo del flujo.>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetPendingRouteTSE]
	-- Add the parameters for the stored procedure here
	@Flow TINYINT --1 RECO, 2 ENTREGA
AS
BEGIN
	
	BEGIN TRY
		SELECT
			'1' 'ResultCode'
		   ,'Datos obtenidos correctamente.' 'Description'

		SELECT
			STUFF((SELECT
					', ' + cr.CodeRoute
				FROM TSERoutePreparationHeader trph WITH (NOLOCK)
				INNER JOIN CatRoute cr WITH (NOLOCK)
					ON cr.IdRoute = trph.IdCatRoute
				WHERE trph.RowStatus = 1
				AND ((@Flow = 1
				AND NOT trph.HasFirstPickupProcess = 1)
				OR (@Flow = 2
				AND NOT (trph.HasFirstPickupProcess = 1
				AND trph.HasFirstArrivalProcess = 1
				AND trph.HasFirstDispatchProcess = 1
				AND trph.HasFirstDeliveryProccess = 1
				AND trph.HasLastDeliveryProccess = 1)))
				FOR XML PATH (''))
			,
			1, 2, '') 'Routes'

	END TRY
	BEGIN CATCH
		SELECT
			'-1' 'ResutlCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END