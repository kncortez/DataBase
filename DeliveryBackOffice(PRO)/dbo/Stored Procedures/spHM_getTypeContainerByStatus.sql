-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <06-07-2022>
-- Description:	<Get list of TypeContainer filter by rowstatus = 1>
-- =============================================
CREATE PROCEDURE spHM_getTypeContainerByStatus
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	[CTC].[IdCatTypeContainer], 
			[CTC].[TypeContainerName],
			[CTC].[TypeContainerSerie],
			[CTC].[TypeContainerDescription]
	FROM [dbo].[CatTypeContainer] CTC
	WHERE [CTC].[RowStatus] = 1;
END