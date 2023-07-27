
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-06-05>
-- Description:	<Obtiene información para la entrega de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetSpecialRouteDeliveryConfirmation]
	-- Add the parameters for the stored procedure here
	@CatRouteId INT
AS
BEGIN
	DECLARE @TSERoutePreparationHeaderId INT = 0
	DECLARE @VehiclePlate VARCHAR(20)
	DECLARE @CustomMark NVARCHAR(50)
	DECLARE @HasLastDeliveryProccess INT

	BEGIN TRY
		
		SELECT
			@TSERoutePreparationHeaderId = trph.IDTSERoutePreparationHeader
		   ,@VehiclePlate = cv.Plate
		   ,@CustomMark = trph.TSECustomsMark
		   ,@HasLastDeliveryProccess = trph.HasLastDeliveryProccess
		FROM TSERoutePreparationHeader trph WITH (NOLOCK)
		LEFT JOIN CatVehicle cv WITH (NOLOCK)
			ON trph.IdCatVehicle = cv.IdVehicle
		WHERE trph.IdCatRoute = @CatRouteId
		AND trph.RowStatus = 1
		AND trph.HasFirstPickupProcess = 1
		AND trph.HasFirstArrivalProcess = 1
		AND trph.HasFirstDispatchProcess = 1
		AND trph.HasFirstDeliveryProccess = 1
		--AND trph.HasLastDeliveryProccess = 0
		
		IF @TSERoutePreparationHeaderId > 0
		BEGIN

			SELECT
			'1' 'ResultCode'
			,'Registros obtenidos correctamente.' 'Description'
			,@TSERoutePreparationHeaderId 'IDTSERoutePreparationHeader'
			,@HasLastDeliveryProccess 'HasLastDeliveryProccess'

			SELECT
				SUM(CASE
					WHEN do.Pieces_Dry + do.Pieces_Cold > 1 THEN 1
					ELSE 0
				END) Guides
			   ,SUM(CASE
					WHEN do.Pieces_Dry + do.Pieces_Cold = 1 THEN 1
					ELSE 0
				END) Envelopes
			   ,SUM(CASE
					WHEN do.Pieces_Dry + do.Pieces_Cold = 1 THEN 0
					ELSE do.Pieces_Dry + do.Pieces_Cold
				END) Boxes
			   ,@VehiclePlate VehiclePlate
			   ,@CustomMark CustomMark
			FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON trpd.GuideSerie = do.Guide_Serie
					AND trpd.GuideNumber = do.Guide_Number
			WHERE trpd.TSERoutePreparationHeaderID = @TSERoutePreparationHeaderId
			AND [trpd].[RowStatus] = 1
			
			SELECT
				CONCAT(do.Guide_Serie, do.Guide_Number) [Guide]
			   ,do.Receiver_Department [Department]
			   ,do.Receiver_Town [Town]
			   ,CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) [Receiver]
			   ,do.Receiver_Address [Address]
			   ,CONCAT(
				Ret.Returned, ' de ', CAST(do.Pieces_Dry + do.Pieces_Cold AS VARCHAR)) [Pieces]
			   ,Ret.Returned [TotalReturned]
			   ,do.Pieces_Dry + do.Pieces_Cold [Total]
			   ,do.Guide_Serie GuideSerie
			   ,do.Guide_Number GuideNumber
			FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON do.Guide_Serie = trpd.GuideSerie
					AND do.Guide_Number = trpd.GuideNumber
			OUTER APPLY (SELECT
					COUNT(1) Returned
				FROM DeliveryOrderPiece dop WITH (NOLOCK)
				INNER JOIN StatusOrder so WITH (NOLOCK)
					ON dop.StatusOrderId = so.StatusOrderId
				WHERE dop.GuideSerie = do.Guide_Serie
				AND dop.GuideNumber = do.Guide_Number
				AND so.OrderDescription = 'Devuelto') Ret
			WHERE trpd.TSERoutePreparationHeaderID = @TSERoutePreparationHeaderId
			AND [trpd].[RowStatus] = 1
			
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