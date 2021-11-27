-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: 2021-15-52,>
-- Description:	<obtiene todos los roles por idsystemplatform>
-- =============================================
CREATE PROCEDURE sphdGetRolbySystem
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
		UPPER(ctr.RolName) + dbo.CapitalizeFirstLetter(' [ ' + UPPER(ctr.RolDescription) + ' ]') [NameValue],
		ctr.RolIdSystem [IdFilter]
		FROM dbo.CatRol ctr 
		WHERE ctr.RolRowStatus = 'TRUE'
		AND (@IdSystem = -1 OR ctr.RolIdSystem = @IdSystem)
		AND (@IdRol = -1 OR ctr.RolIdRol = @IdRol)
	END 
END
GO
