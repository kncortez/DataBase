-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <26-08-2022>
-- Description:	<Get detail pieces in ACT>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetDetailPiecesAct]
	@ActId AS INT,
	@GuideSerie AS NVARCHAR(5),
	@GuideNumber AS NVARCHAR(15),
	@DateOfRoute AS DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT		[ADP].[IdActDetailPiece],
				[ADP].[ActDetailId],
				[AD].[GuideSerie],
				[AD].[GuideNumber],
				[ADP].[PieceNumber]
	FROM		[dbo].[ActDetailPiece] ADP
	INNER JOIN	[dbo].[ActDetail] AD
		ON		[ADP].[ActDetailId] = [AD].[IdActDetail]
		AND		[AD].[GuideSerie] = @GuideSerie
		AND		[AD].[GuideNumber] = @GuideNumber
		AND		[ADP].[RowStatus] = 1
	INNER JOIN	[dbo].[Act] A
		ON		[AD].ActId = [A].[IdAct]
		AND		[A].[IdAct] = @ActId
		AND		CAST([A].[DateOfRoute] AS DATE) = CAST(@DateOfRoute AS DATE)
		AND		[A].[RowStatus] = 1;
END