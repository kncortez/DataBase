-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <14-09-2022>
-- Description:	<Get general numbers from Linehaul Route Settlement>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetGeneralNumbersLinehaulRouteSettlement]
	@LinehaulRouteSettlementId AS INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT	[LRS].[GuidesReceived],
			[LRS].[ContainersReceived],
			[LRS].[GuidePiecesReceived],
			[LRS].[GuidePiecesMissing]
	FROM	[dbo].[LinehaulRouteSettlement] LRS
	WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId;
END