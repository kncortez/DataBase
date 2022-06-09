-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: 2021-15-52,>
-- Description:	<obtiene todos los roles por idsystemplatform>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetRolbySystems]
	-- Add the parameters for the stored procedure here
	@IdRol AS INT = -1,
	@IdSystems AS VARCHAR(50) = 'all',
	@Option AS INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF (@Option  = 0)
	BEGIN
		--DECLARE @IntSystem INT;
		--SET @IntSystem = (CASE WHEN  @IdSystems = 'all' THEN -1 ELSE 0 END );
		IF OBJECT_ID('tempdb.dbo.#parSystem', 'U') IS NOT NULL DROP TABLE #parSystem;

		create table #parSystem(
			pkId INT
		)
				
		IF @IdSystems = 'all' 
			BEGIN
				INSERT into #parSystem
				SELECT null items
			END 
		ELSE 
			BEGIN
				INSERT into #parSystem
				SELECT items
				FROM DeliveryBackOffice.dbo.fn_Splits(@IdSystems,',');
			END		

		SELECT ctr.RolIdRol [IdValue],
				UPPER(ctr.RolName) + dbo.CapitalizeFirstLetter(' [ ' + UPPER(cts.SysNameSystem) + ' - ' + UPPER(ctr.RolDescription) + ' ]') [NameValue],
				ctr.RolIdSystem [IdFilter]
		FROM #parSystem prm
		JOIN DeliveryBackOffice.dbo.catrol ctr
			ON isnull(prm.pkId,ctr.rolidsystem) = ctr.rolidsystem
		JOIN dbo.CatSystem cts ON cts.SysIdSystem = ctr.RolIdSystem
		WHERE ctr.RolRowStatus = 'TRUE'
		AND (@IdRol = -1 OR ctr.RolIdRol = @IdRol);
		
		drop table #parSystem

	END 
END


