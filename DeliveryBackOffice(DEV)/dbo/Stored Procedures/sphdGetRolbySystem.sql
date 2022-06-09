-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: 2021-15-52,>
-- Description:	<obtiene todos los roles por idsystemplatform>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetRolbySystem]
	-- Add the parameters for the stored procedure here
	@IdRol AS INT = -1,
	@IdSystem AS INT = -1,
	@Option AS INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF (@Option  = 0)
	BEGIN
		SELECT ctr.RolIdRol [IdValue],
		UPPER(ctr.RolName) + dbo.CapitalizeFirstLetter(' [ '+ UPPER(cts.SysNameSystem) + ' - '  + UPPER(ctr.RolDescription) + ' ]') [NameValue],
		ctr.RolIdSystem [IdFilter]
		FROM dbo.CatRol ctr 
		JOIN dbo.CatSystem cts ON cts.SysIdSystem = ctr.RolIdSystem
		WHERE ctr.RolRowStatus = 'TRUE'
		AND (@IdSystem = -1 OR ctr.RolIdSystem = @IdSystem)
		AND (@IdRol = -1 OR ctr.RolIdRol = @IdRol)
	END 
END
