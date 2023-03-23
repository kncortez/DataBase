-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <22-03-2023>
-- Description:	<Get Courier App copyright and version>
-- =============================================
CREATE PROCEDURE [dbo].[spCA_GetVersionData] 
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CAVersion NVARCHAR(50);
	DECLARE @CACopyright NVARCHAR(50);
    
	SET @CAVersion = (	SELECT ISNULL([CP].[Value], '') 
						FROM	[dbo].[ConfigParams] CP
						WHERE	[CP].[Name] = 'CourierAppVersion');

	SET @CACopyright = (SELECT CONCAT(YEAR(SYSDATETIME()), ' ', ISNULL([CP].[Value], ''))
						FROM	[dbo].[ConfigParams] CP
						WHERE	[CP].[Name] = 'CourierAppCopyright');

	SELECT	@CAVersion [CAVersion],
			@CACopyright [CACopyright];
END