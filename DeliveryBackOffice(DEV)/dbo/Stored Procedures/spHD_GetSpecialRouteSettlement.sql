-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-06-03>
-- Description:	<Obtiene información para la liquidación de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetSpecialRouteSettlement]
	-- Add the parameters for the stored procedure here
	@CatRouteId INT
AS
BEGIN
	DECLARE @TSERoutePreparationHeaderId INT = 0
	DECLARE @CourierId INT
	DECLARE @CatVehicleId INT

	BEGIN TRY
		
		SELECT
			@TSERoutePreparationHeaderId = trph.IDTSERoutePreparationHeader
		   ,@CourierId = trph.SenderReceiverId
		   ,@CatVehicleId = trph.IdCatVehicle
		FROM TSERoutePreparationHeader trph WITH (NOLOCK)
		WHERE trph.IdCatRoute = @CatRouteId
		AND trph.RowStatus = 1
		AND trph.HasFirstPickupProcess = 1
		AND trph.HasFirstArrivalProcess = 1
		AND trph.HasFirstDispatchProcess = 1
		AND trph.HasFirstDeliveryProccess = 0
		
		IF @TSERoutePreparationHeaderId > 0
		BEGIN

			SELECT
			'1' 'ResultCode'
			,'Registros obtenidos correctamente.' 'Description'

			SELECT
				CONCAT(sr.First_Name, ' ', sr.Last_Name) Courier
			   ,cv.Plate Vehicle
			FROM SenderReceiver sr WITH (NOLOCK)
			INNER JOIN CatVehicle cv WITH (NOLOCK)
				ON cv.IdVehicle = @CatVehicleId
			WHERE sr.ID = @CourierId
			
			SELECT
				CONCAT(do.Guide_Serie, do.Guide_Number) [Guide]
			   ,do.Receiver_Department [Department]
			   ,do.Receiver_Town [Town]
			   ,CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) [Receiver]
			   ,do.Receiver_Address [Address]
			   ,do.Pieces_Dry + do.Pieces_Cold [Pieces]
			   ,ISNULL(ca.OrderDescription, so.OrderDescription) [Status]
			FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON do.Guide_Serie = trpd.GuideSerie
					AND do.Guide_Number = trpd.GuideNumber
			INNER JOIN StatusOrder so WITH (NOLOCK)
				ON so.StatusOrderId = do.StatusOrderId
			OUTER APPLY (SELECT TOP 1
					so.OrderDescription
				FROM DeliveryOrderDetail dod WITH (NOLOCK)
				INNER JOIN StatusOrder so WITH (NOLOCK)
				ON so.StatusOrderId = dod.StatusOrderId
				WHERE dod.Guide_Serie = do.Guide_Serie
				AND dod.Guide_Number = do.Guide_Number
				AND dod.RowStatus = 1
				AND so.OrderDescription = 'Entregado') ca
			WHERE trpd.TSERoutePreparationHeaderID = @TSERoutePreparationHeaderId
			AND trpd.RowStatus = 1
			AND (do.Pieces_Dry + do.Pieces_Cold) > 1
		END
		ELSE
		BEGIN
			SELECT
			'-2' 'ResultCode'
			,'No se encontraron registros. La ruta no se encuentra en un flujo válido o ya fué liquidada.' 'Description'
		END
	END TRY
	BEGIN CATCH

		SELECT
			'-1' 'ResultCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END