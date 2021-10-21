USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sphdGetVpCodeOfReference]    Script Date: 21/10/2021 09:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-10-21>
-- Description:	<Devuelve el CodeOfReference y el StationId del usuario logeado>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetVpCodeOfReference]
	-- Add the parameters for the stored procedure here
	@CodeUser as bigint,
	@UserName as nvarchar(50),
	@IdSystem as int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @VpCodeOfReference INT
	DECLARE @StationId INT
	DECLARE @StationType INT
	SET NOCOUNT ON;

	SELECT 
		@StationId = cs.IdStation
		,@VpCodeOfReference = cs.CodeOfReference
		,@StationType = cs.StationType
	FROM InternalUser iu
	JOIN RegisterUser ru
		ON iu.RegisterUserID = ru.UsrIdUser
		AND ru.UsrRowStatus = 1
	JOIN RolByUserBySystem rus
		ON ru.UsrIdUser = rus.RusIdUser
		AND rus.RusRowStatus = 1
	JOIN CatStation cs
		ON rus.StationId = cs.IdStation
		AND cs.RowStatus = 1
	WHERE iu.IdUser = @CodeUser 
		AND iu.Username = @UserName
		AND rus.RusIdSystem = @IdSystem
		AND iu.RowStatus = 1


	IF @StationId IS NULL
		SELECT @StationId = -1 
			   ,@VpCodeOfReference = 999
	ELSE
		IF @StationType = 1
			SET @VpCodeOfReference = 999

	SELECT @VpCodeOfReference VpCodeOfReference, @StationId StationId
 	   
END
