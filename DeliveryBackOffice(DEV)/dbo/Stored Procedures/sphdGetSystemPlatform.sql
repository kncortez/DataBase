-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-10-15>
-- Description:	<get all system platform of Hermes>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetSystemPlatform]
	-- Add the parameters for the stored procedure here
	@IdSystem AS INT = -1,
	@Option AS INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (@Option = 0)
	BEGIN
		SELECT [SysIdSystem] [IdValue],
			UPPER([SysNameSystem]) + ' [ ' + [SysPlataform] + ' - ' + [SysDescription] +' ]' [NameValue]
		FROM [DeliveryBackOffice].[dbo].[CatSystem] cts
		WHERE cts.SysRowStatus = 'TRUE'
		AND (@IdSystem = -1 OR cts.SysIdSystem = @IdSystem)
		AND cts.SysShow = 'TRUE'
	END 
END
