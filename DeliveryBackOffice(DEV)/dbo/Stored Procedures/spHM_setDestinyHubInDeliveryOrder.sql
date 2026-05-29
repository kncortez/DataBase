-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <19-07-2022>
-- Description:	<Set destiny HUB in DeliveryOrder item>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_setDestinyHubInDeliveryOrder] 
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50),
	@IdHubDestiny AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_DELIVERY_ORDER AS INT;	-- Delivery Order item

	SET @EXISTING_DELIVERY_ORDER = (SELECT COUNT([DO].[Guide_Number]) AS CONT
									FROM	[dbo].[DeliveryOrder] DO WITH(NOLOCK)
									WHERE	[DO].[Guide_Serie] = @GuideSerie
										AND	[DO].[Guide_Number] = @GuideNumber);

	IF (@EXISTING_DELIVERY_ORDER > 0) 
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE	[DeliveryOrder]
				SET		[HubDestinationId] = @IdHubDestiny,
						[TokenUpdated] = @TknUser, 
						[DateUpdated] = SYSDATETIME()
				WHERE	[Guide_Serie] = @GuideSerie
					AND [Guide_Number] = @GuideNumber;

				SELECT	[DO].[Guide_Serie],
						[DO].[Guide_Number],
						COALESCE([DO].[Pieces_Dry], 0) AS Pieces_Dry,
						COALESCE([DO].[Pieces_Cold], 0) AS Pieces_Cold,
						COALESCE([DO].[ReceiverIdTownship], 0) AS ReceiverIdTownship,
						[DO].[Receiver_Town],
						[DO].[Receiver_Department],
						[DO].[Receiver_Address],
						--COALESCE([DO].[Receiver_Zone], 0) AS Receiver_Zone,
						COALESCE(TRY_CAST([DO].[Receiver_Zone] AS INT), 0) AS Receiver_Zone,
						COALESCE(TRY_CAST([DO].[HubDestinationId] AS INT), 0) AS HubDestinationId,
						[HL].[HubAbbreviation],
						COALESCE([DO].[StatusOrderId], 0) AS StatusOrderId,
						[SO].[OrderDescription]
				FROM	[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				LEFT JOIN [DBO].[HubLogistics] HL
					ON	[DO].[HubDestinationId] = [HL].[IdHubLogistic]
				INNER JOIN [DBO].[StatusOrder] SO
					ON	[DO].[StatusOrderId] = [SO].[StatusOrderId]
				WHERE	[DO].[Guide_Serie] = @GuideSerie
					AND [DO].[Guide_Number] = @GuideNumber;

				IF (@@TRANCOUNT > 0)
					COMMIT TRANSACTION
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
END