USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sphdGetVpCodeOfReference]    Script Date: 10/23/2021 10:35:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-10-21>
-- Description:	<Devuelve el CodeOfReference y el StationId del usuario logeado>
-- =============================================
alter PROCEDURE [dbo].[sphdGetVpCodeOfReference]
	-- Add the parameters for the stored procedure here
	@CodeUser as bigint,
	@UserName as nvarchar(50),
	@IdSystem as int 
AS
BEGIN	
	DECLARE @VpCodeOfReference INT
	DECLARE @StationId INT
	DECLARE @StationType INT	
	DECLARE @StationName VARCHAR(200)	
	DECLARE @StationDetail VARCHAR(200)

	SELECT 
		@StationId = cs.IdStation
		,@VpCodeOfReference = cs.CodeOfReference
		,@StationType = cs.StationType
		,@StationName= IIF(cs.StationType = 1,'HUB ','') + cs.StationName 	
	    ,@StationDetail = IIF(cs.StationType = 1,
		 --CONVERT(VARCHAR(50),HBL.IdHubLogistic)
		'',CONVERT(VARCHAR(50),CONVERT(VARCHAR(50),VPC.CodeOfReference) + ' ' + VPC.Address))	
	FROM DeliveryBackOffice.dbo.InternalUser iu
	JOIN DeliveryBackOffice.dbo.RegisterUser ru
		ON iu.RegisterUserID = ru.UsrIdUser
		AND ru.UsrRowStatus = 1
	JOIN DeliveryBackOffice.dbo.RolByUserBySystem rus
		ON ru.UsrIdUser = rus.RusIdUser
		AND rus.RusRowStatus = 1
	JOIN DeliveryBackOffice.dbo.CatStation cs
		ON rus.StationId = cs.IdStation
		AND cs.RowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
	ON VPC.CodeOfReference = cs.CodeOfReference AND cs.StationType = 2
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

	SELECT @VpCodeOfReference VpCodeOfReference, @StationId StationId,@StationName StationName,@StationDetail StationDetail
 	   
END
