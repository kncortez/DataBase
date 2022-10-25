-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <20-07-2022>
-- Description:	<Update DeliveryOrderPiece Status>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_updateDeliveryOrderPieceStatus]
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50),
	@NoPiece AS INT,
	@IsSettlement AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @STATUS_ORDER_ID AS INT;	-- StatusOrder

	IF (@IsSettlement = 0)
		BEGIN
			SET @STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'En preparación de traslado');
		END
	ELSE
		BEGIN
			SET @STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Arribó a las instalaciones');
		END

	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE	[DeliveryOrderPiece]
		SET		[StatusOrderId] = @STATUS_ORDER_ID
		WHERE	[GuideSerie] = @GuideSerie
			AND [GuideNumber] = @GuideNumber
			AND [NoPiece] = @NoPiece;

		SELECT	[DOP].[GuidePiece],
				[DOP].[GuideSerie],
				[DOP].[GuideNumber],
				[DOP].[PiecePhysicalWeight],
				[DOP].[PieceHeight],
				[DOP].[PieceWidth],
				[DOP].[PieceLength],
				[DOP].[PieceWeight],
				[DOP].[Detail],
				[DOP].[Currency],
				[DOP].[Amount],
				[DOP].[DateCreated],
				[DOP].[fragile],
				[DOP].[IsPickup],
				[DOP].[NoPiece],
				[DOP].[IsDry],
				[DOP].[StatusOrderId]
		FROM	[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
		WHERE	[DOP].[GuideSerie] = @GuideSerie
			AND	[DOP].[GuideNumber] = @GuideNumber
			AND [DOP].[NoPiece] = @NoPiece;

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