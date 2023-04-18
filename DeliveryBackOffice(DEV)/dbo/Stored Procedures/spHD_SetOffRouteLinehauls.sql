
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-11>
-- Description:	<Marga una guía como fuera de ruta Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_SetOffRouteLinehauls]
	@IdLinehaulRoutePreparation INT,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@IsOffRoute BIT,
	@HubLogisticsId INT,
	@Token NVARCHAR(50)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @StatusOrderId INT
		DECLARE @StatusName NVARCHAR(100)

		SELECT
			@StatusOrderId = StatusOrderId
		   ,@StatusName = OrderDescription
		FROM StatusOrder WITH (NOLOCK)
		WHERE OrderDescription = 'Guía fuera de ruta'


		IF @IsOffRoute = 0
		BEGIN

			UPDATE DeliveryOrder
			SET StatusOrderId = @StatusOrderId
			WHERE Guide_Serie = @GuideSerie
			AND Guide_Number = @GuideNumber

			INSERT INTO [dbo].[DeliveryOrderDetail] ([Guide_Serie]
			, [Guide_Number]
			, [StatusOrderId]
			, [UserCreated]
			, [DateCreated]
			, [DateCreatedInSystem]
			, [Observations]
			, [Temperature_Celsius]
			, [PieceId]
			, [RowStatus])
				VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @Token, GETDATE(), GETDATE(), NULL, NULL, NULL, 1)

			UPDATE lrpcd
			SET IsOffRoute = 1
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			FROM LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK) 
			INNER JOIN LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
				ON lrpcd.LinehaulRoutePreparationContainerId = lrpc.IdLinehaulRoutePreparationContainer
				AND lrpcd.RowStatus = 1
			WHERE lrpc.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
			AND lrpcd.GuideSerie = @GuideSerie
			AND lrpcd.GuideNumber = @GuideNumber

			UPDATE lrscd
			SET IsOffRoute = 1
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			FROM LinehaulRouteSettlementContainerDetail lrscd WITH (NOLOCK)
			INNER JOIN LinehaulRouteSettlementContainer lrsc WITH (NOLOCK)
				ON lrscd.LinehaulRouteSettlementContainerId = lrsc.IdLinehaulRouteSettlementContainer
				AND lrscd.RowStatus = 1
			INNER JOIN LinehaulRouteSettlement lrs WITH(NOLOCK)
				ON lrsc.LinehaulRouteSettlementId = lrs.IdLinehaulRouteSettlement

			WHERE lrs.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
			AND lrscd.GuideSerie = @GuideSerie
			AND lrscd.GuideNumber = @GuideNumber
		END
		ELSE
		BEGIN
			SELECT
				@StatusOrderId = do.StatusOrderId
			   ,@StatusName = so.OrderDescription
			FROM StatusOrder so WITH (NOLOCK)
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON so.StatusOrderId = do.StatusOrderId
		END

		UPDATE do
		SET HubOriginId =
			CASE
				WHEN do.IsLastMileReturn = 1 THEN @HubLogisticsId
				ELSE do.HubOriginId
			END
		   ,HubDestinationId =
			CASE
				WHEN do.IsLastMileReturn = 1 THEN do.HubDestinationId
				ELSE @HubLogisticsId
			END
		FROM DeliveryOrder do WITH (NOLOCK)
		WHERE do.Guide_Serie = @GuideSerie
		AND do.Guide_Number = @GuideNumber

		COMMIT TRANSACTION

		SELECT
			1 'StatusCode'
		   ,'Datos actualizados correctamente.' 'Description'
		   ,@StatusName 'StatusName'


	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT
			-1 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'

	END CATCH
END