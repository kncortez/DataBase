-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <24-08-2022>
-- Description:	<End settlement process>
-- =============================================
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <05-11-2025>
-- Description:	<Se actualizan a estado en revision las guias multipiezas que no han sido escaneadas por completo>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_EndLinehaulRouteSettlement]
	@LinehaulRouteSettlementId AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRS AS INT;					-- LinehaulRouteSettlement
	DECLARE @LRP_ID AS INT;							-- LinehaulRouteSettlement
	DECLARE @PIECES_MISSING_IN_SETTLEMENT AS INT;	-- LinehaulRouteSettlement
	DECLARE @LIQUIDATED_STATUS_ID AS INT;			-- CatLinehaulStatus
	DECLARE @IN_TRANSIT_STATUS_ID AS INT;			-- CatLinehaulStatus
	DECLARE @Status INT

	SET @LIQUIDATED_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'LIQUIDATED');

	SET @IN_TRANSIT_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'IN TRANSIT');
	
	SET @EXISTING_LRS = (SELECT  COUNT([LRS].[IdLinehaulRouteSettlement]) AS CONT
						FROM	[dbo].[LinehaulRouteSettlement] LRS
						WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId
							AND [LRS].[CatLinehaulStatusId] != @LIQUIDATED_STATUS_ID);

	SET @LRP_ID = (SELECT	[LRS].[LinehaulRoutePreparationId]
					FROM	[dbo].[LinehaulRouteSettlement] LRS
					WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId);


	SET @Status = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'En Revisión')

	SET @PIECES_MISSING_IN_SETTLEMENT = (SELECT		COUNT([CTC].[TypeContainerSerie]) AS CONT
										FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
										INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
											ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
										INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
											ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
											AND		[LRPCD].[RowStatus] = 1
										INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
											ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]											
										INNER JOIN	[dbo].[Container] C
											ON		[LRPC].[ContainerId] = [C].[IdContainer]
										INNER JOIN	[dbo].[CatTypeContainer] CTC
											ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
										WHERE		[LRPCDP].[CatLinehaulStatusId] = @IN_TRANSIT_STATUS_ID
											AND		[LRPCDP].[ActCode] IS NULL
											AND		[LRP].[IdLinehaulRoutePreparation] = @LRP_ID);

	IF (@EXISTING_LRS = 0)
		-- SETTLEMENT DOESN'T EXIST
		BEGIN
			SELECT 0 [spResult], 'NO se encontró ningún manifiesto de liquidación activo con los datos ingresados.' [spMessage];
			RETURN;
		END

	IF (@PIECES_MISSING_IN_SETTLEMENT > 0)
		-- PIECES MISSING IN SETTLEMENT
	BEGIN
		BEGIN TRY
			BEGIN TRAN; 

			DECLARE @Guides TABLE (GuideSerie NVARCHAR(3), GuideNumber INT);
			-- SE PASAN A ESTADO EN REVISION LAS GUIAS MULTIPIEZAS NO ESCANEADAS
			INSERT INTO @Guides (GuideSerie, GuideNumber)
			SELECT DISTINCT
				LRPCD.GuideSerie,
				LRPCD.GuideNumber
			FROM dbo.LinehaulRoutePreparationContainerDetailPiece LRPCDP
			INNER JOIN dbo.LinehaulRoutePreparationContainerDetail LRPCD
				ON LRPCDP.LinehaulRoutePreparationContainerDetailId = LRPCD.IdLinehaulRoutePreparationContainerDetail
			INNER JOIN dbo.LinehaulRoutePreparationContainer LRPC
				ON LRPCD.LinehaulRoutePreparationContainerId = LRPC.IdLinehaulRoutePreparationContainer
			INNER JOIN dbo.LinehaulRoutePreparation LRP
				ON LRPC.LinehaulRoutePreparationId = LRP.IdLinehaulRoutePreparation
			INNER JOIN dbo.Container C
				ON LRPC.ContainerId = C.IdContainer
			INNER JOIN dbo.CatTypeContainer CTC
				ON C.CatTypeContainerId = CTC.IdCatTypeContainer
			WHERE LRPCDP.CatLinehaulStatusId = @IN_TRANSIT_STATUS_ID
			  AND LRPCDP.ActCode IS NULL
			  AND LRPCD.RowStatus = 1
			  AND LRP.IdLinehaulRoutePreparation = @LRP_ID;

			 --CREAMOS LOG DE CAMBIO DE ESTADO
			 INSERT INTO DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, RowStatus)
			 SELECT G.GuideSerie,
					G.GuideNumber,
					@Status,
					@TknUser,
					GETDATE(),
					GETDATE(),
					1
			 FROM @Guides G

			UPDATE DO
			SET DO.StatusOrderId = @Status
			FROM dbo.DeliveryOrder DO
			INNER JOIN @Guides T
				ON DO.Guide_Serie = T.GuideSerie
			   AND DO.Guide_Number = T.GuideNumber
			WHERE ISNULL(DO.StatusOrderId, 0) <> @Status;
			
			COMMIT TRAN;

		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
				ROLLBACK TRAN;

			SELECT
				0 AS spResult,
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorProcedure,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS spMessage;
			RETURN;
		END CATCH
	END 

	BEGIN TRANSACTION
	BEGIN TRY

	-- CLOSE DISPATCH CONTAINERS
		UPDATE	[dbo].[LinehaulRoutePreparationContainer]
		SET		[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID
		WHERE	[LinehaulRoutePreparationId] = @LRP_ID
			AND	[CatLinehaulStatusId] = @IN_TRANSIT_STATUS_ID;

	-- CLOSE DISPATCH
		UPDATE	[dbo].[LinehaulRoutePreparation]
		SET		[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID,
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME()
		WHERE	[IdLinehaulRoutePreparation] = @LRP_ID;

	-- END SETTLEMENT 
		UPDATE	[dbo].[LinehaulRouteSettlement]
		SET		[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID,
				[EndDateLinehaulRouteSettlement] = SYSDATETIME(),
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME()
		WHERE	[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId;

		SELECT 1 [spResult], 'Liquidación de linehaul ha sido finalizada con éxito.' [spMessage];

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT 0 [spResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [spMessage];

		ROLLBACK TRANSACTION
	END CATCH

END