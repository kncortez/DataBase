-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <12-07-2022>
-- Description:	<Get and validate a DeliveryOrder Guide by serie and number>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getGuideByNumber]
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IS_HUB_DESTINY AS INT;		-- Delivery Order
	DECLARE @HUB_ID AS INT;				-- Hub Logistics

	SET @IS_HUB_DESTINY = (	SELECT  COALESCE([DO].[HubDestinationId], 0) AS HubDestinationId
							FROM	[dbo].[DeliveryOrder] DO WITH (NOLOCK)
							WHERE	[DO].[Guide_Serie] = @GuideSerie
								AND [DO].[Guide_Number] = @GuideNumber);

	BEGIN TRANSACTION
	BEGIN TRY
		IF (@IS_HUB_DESTINY = 0)
			BEGIN
				UPDATE	[dbo].[DeliveryOrder]
				SET		[HubDestinationId] = (	SELECT IdHubLogistic
												FROM HubLogistics
												WHERE HubAbbreviation = [dbo].[fn_get_hub_destiny](@GuideSerie, @GuideNumber))
				WHERE	[Guide_Serie] = @GuideSerie 
					AND [Guide_Number] = @GuideNumber;
			END

		SELECT	[DO].[Guide_Serie], 
				[DO].[Guide_Number],
				COALESCE([DO].[Pieces_Dry], 0) AS Pieces_Dry,
				COALESCE([DO].[Pieces_Cold], 0) AS Pieces_Cold,
				COALESCE([DO].[ReceiverIdTownship], 0) AS ReceiverIdTownship,
				[DO].[Receiver_Town],
				[DO].[Receiver_Department],
				[DO].[Receiver_Address],
				COALESCE([DO].[Receiver_Zone], '0') AS Receiver_Zone,
				COALESCE([DO].[HubDestinationId], 0) AS HubDestinationId,
				[HL].[HubAbbreviation],
				COALESCE([DO].[StatusOrderId], 0) AS StatusOrderId,
				[SO].[OrderDescription]
		FROM	[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		LEFT JOIN [dbo].[HubLogistics] HL
			ON	[DO].[HubDestinationId] = [HL].[IdHubLogistic]
		INNER JOIN [dbo].[StatusOrder] SO
			ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
			AND ([SO].[OrderDescription] = 'Generado'  COLLATE Latin1_General_CI_AI  OR
				[SO].[OrderDescription] = 'Recolectado'  COLLATE Latin1_General_CI_AI  OR
				[SO].[OrderDescription] = 'Arribó a las instalaciones'  COLLATE Latin1_General_CI_AI  OR
				[SO].[OrderDescription] = 'En inventario'  COLLATE Latin1_General_CI_AI  OR
				[SO].[OrderDescription] = 'En Tránsito'  COLLATE Latin1_General_CI_AI  OR
				[SO].[OrderDescription] = 'En preparación de traslado'  COLLATE Latin1_General_CI_AI  OR
				[SO].[OrderDescription] = 'Declarado para Devolución'  COLLATE Latin1_General_CI_AI  OR
				[SO].[OrderDescription] = 'Trasladado a Hub'  COLLATE Latin1_General_CI_AI )
		WHERE	[DO].[Guide_Serie] = @GuideSerie
		AND		[DO].[Guide_Number] = @GuideNumber;

		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		SELECT 0 [spResult],
			ERROR_NUMBER() AS [ErrorNumber],
			ERROR_SEVERITY() AS [ErrorSeverity],
			ERROR_STATE() AS [ErrorState],
			ERROR_PROCEDURE() AS [ErrorProcedure],
			ERROR_LINE() AS [ErrorLine],
			ERROR_MESSAGE() AS [ErrorMessage];

		ROLLBACK TRANSACTION
	END CATCH
END