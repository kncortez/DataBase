-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <07/07/2022>
-- Description:	<Get list of series by status row>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getCatSeriesByRowStatus]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	[CS].[IdSerie]
	FROM [dbo].[CatSeries] CS
	WHERE [CS].[SerieStatus] = 1;
END