-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <14-07-2022>
-- Description:	<GetGuidePieceByNumber>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getGuidePieceByNumber]
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(25),
	@GuidePiece AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
	FROM	[dbo].[DeliveryOrderPiece] DOP
	WHERE	[DOP].[GuideSerie] = @GuideSerie
		AND	[DOP].[GuideNumber] = @GuideNumber
		AND [DOP].[NoPiece] = @GuidePiece;
END