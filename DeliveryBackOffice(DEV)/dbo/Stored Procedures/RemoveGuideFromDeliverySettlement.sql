-- =============================================
-- Author:      <Tito Garcia>
-- Create date: <07-08-2024>
-- Description: <Se remueve la guia del manifiesto original ya que se va a cambiar la fecha de la entrega>
-- =============================================
CREATE PROCEDURE [dbo].[RemoveGuideFromDeliverySettlement]
@GuideSerie NVARCHAR(2) = '',
@GuideNumber INT= 0

AS
BEGIN
	DECLARE @DeliveryOrderBySettlementId INT;
	DECLARE @PiecesDry INT;
	DECLARE @PiecesCold INT;
	
	SELECT TOP 1 
		@DeliveryOrderBySettlementId = rp.DeliveryOrderBySettlementId,
		@PiecesDry = rp.PiecesDry,
		@PiecesCold = rp.PiecesCold
	FROM RoutePreparation rp WITH(NOLOCK)
		INNER JOIN RoutePreparationDetail rpd WITH(NOLOCK)
			ON rp.IdRoutePreparation = rpd.RoutePreparationId
		INNER JOIN DeliveryOrder DO WITH(NOLOCK)
			ON rpd.Guide_Number = DO.Guide_number 
		LEFT JOIN DeliveryOrderBySettlement dobs WITH(NOLOCK)
			ON rp.DeliveryOrderBySettlementId = dobs.ID
	WHERE DO.Guide_number = @GuideNumber
		AND DO.Guide_Serie = @GuideSerie
		AND rp.RowStatus = 1
		AND rpd.IsCustomerReschedule = 0

	BEGIN TRANSACTION
		BEGIN TRY

		-- Se actualizan contadores en el manifiesto original (se quita la guia)
		UPDATE DeliveryOrderBySettlement 
			SET Pieces_Dry_Dispatched = Pieces_Dry_Dispatched - @PiecesDry
				, Pieces_Cold_Dispatched =  Pieces_Cold_Dispatched - @PiecesCold
				, Guides_Dispatched = Guides_Dispatched - 1
		WHERE ID = @DeliveryOrderBySettlementId

		-- Se inactiva la ruta que fue reprogramada
		UPDATE DeliverySettlementDetail SET RowStatus = 0 
		WHERE Guide_Serie = @GuideSerie 
			AND Guide_Number = @GuideNumber  
			AND ID_DeliveryOrderBySettlement = @DeliveryOrderBySettlementId 

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
				SELECT ERROR_MESSAGE() -- retornar mensaje de error
		END CATCH;

		IF @@TRANCOUNT > 0 
			BEGIN
			COMMIT TRANSACTION;
				SELECT 'La guía fue removida satisfactoriamente' as ResultMessage 
		END
END