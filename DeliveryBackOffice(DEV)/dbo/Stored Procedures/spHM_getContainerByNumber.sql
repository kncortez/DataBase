-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <07-07-2022>
-- Description:	<Get a container filter by serie and number>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getContainerByNumber]
	@ContainerSerie AS VARCHAR(20),
	@ContainerNumber AS VARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT	[CNT].[IdContainer], 
			[CNT].[CatTypeContainerId], 
			[CTC].[TypeContainerName], 
			[CTC].[TypeContainerSerie], 
			[CNT].[ContainerNumber]
	FROM [dbo].[Container] CNT
		INNER JOIN [dbo].[CatTypeContainer] CTC
		ON [CNT].[CatTypeContainerId] = [CTC].[IdCatTypeContainer] 
			AND [CTC].[TypeContainerSerie] = @ContainerSerie
			AND [CNT].[ContainerNumber] = @ContainerNumber
			AND [CNT].[RowStatus] = 1;
END