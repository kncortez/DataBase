-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <19-10-2022>
-- Description:	<Obtener valores de configParams>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetConfigParams] 
	@Name AS VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT	[CP].[ConfigParamsId],
			[CP].[Name],
			[CP].[Description],
			[CP].[Value]
	FROM	[dbo].[ConfigParams] CP
	WHERE	[CP].[Name] = @Name
		AND [CP].[Status] = 1;
END