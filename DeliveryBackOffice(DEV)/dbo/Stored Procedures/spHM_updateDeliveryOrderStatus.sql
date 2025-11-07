-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <20-07-2022>
-- Description:	<Update DeliveryOrder Status>
-- =============================================
-- Propósito: Agregar parámetro @IdStation para rastrear estación en escala
-- Autor:     <Freddy Camposeco>
-- Historia:  <FDAPI-4723>
-- Fecha:     <2025-10-15>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_updateDeliveryOrderStatus]
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50),
	@IsSettlement AS INT,
	@TknUser AS NVARCHAR(50),
	@IdStation AS INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NEW_STATUS_ID AS INT;	-- StatusOrder
	DECLARE @INSERTED_DOC AS INT;	-- Last doc ID inserted

	IF (@IsSettlement = 1) 
		BEGIN
			-- Status for settlement
			SET @NEW_STATUS_ID =(SELECT	[SO].[StatusOrderId]
								FROM	[dbo].[StatusOrder] SO
								WHERE	[SO].[OrderDescription] = 'Trasladado a Hub');
		END
	ELSE
		BEGIN
			-- Status for dispatch
			SET @NEW_STATUS_ID =(SELECT	[SO].[StatusOrderId]
								FROM	[dbo].[StatusOrder] SO
								WHERE	[SO].[OrderDescription] = 'En preparación de traslado');
		END

	IF (@NEW_STATUS_ID > 0)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY

				INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
							([Guide_Serie],
							 [Guide_Number],
							 [StatusOrderId],
							 [UserCreated],
							 [DateCreated],
							 [DateCreatedInSystem],
							 [RowStatus],
							 [StationId])
					VALUES	(@GuideSerie,
							 @GuideNumber,
							 @NEW_STATUS_ID,
							 @TknUser,
							 SYSDATETIME(),
							 SYSDATETIME(),
							 1,
							 @IdStation);

				UPDATE	[DeliveryOrder]
				SET		[StatusOrderId] = @NEW_STATUS_ID,
						[TokenUpdated] = @TknUser,
						[DateUpdated] = SYSDATETIME()
				WHERE	[Guide_Serie] = @GuideSerie
					AND [Guide_Number] = @GuideNumber;

				SELECT	[DO].[Guide_Serie],
						[DO].[Guide_Number],
						[DO].[Pieces_Dry],
						[DO].[Pieces_Cold],
						[DO].[ReceiverIdSettlement],
						[DO].[ReceiverIdTownship],
						[DO].[Receiver_Town],
						[DO].[Receiver_Department],
						[DO].[Receiver_Address],
						[DO].[Receiver_Zone],
						[DO].[HubDestinationId],
						[HL].[HubAbbreviation],
						[DO].[StatusOrderId],
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