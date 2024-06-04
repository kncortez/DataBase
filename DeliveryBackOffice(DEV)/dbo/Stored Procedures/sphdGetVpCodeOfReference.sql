-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-10-21>
-- Description:	<Devuelve el CodeOfReference y el StationId del usuario logeado>
-- =============================================
-- Author:      <Daniel,Ramirez>
-- Update date: <2024-05-17>
-- Description: <Agregar filtro para Honduras>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetVpCodeOfReference]
(
  -- Add the parameters for the stored procedure here
  @CodeUser AS BIGINT,
  @UserName AS NVARCHAR(50),
  @IdSystem AS INT 
)
AS
BEGIN
	DECLARE @VpCodeOfReference INT
	DECLARE @StationId INT
	DECLARE @StationType INT	
	DECLARE @StationName VARCHAR(200)	
	DECLARE @StationDetail VARCHAR(200)
    DECLARE @Country NVARCHAR(2)

	SELECT 
		@StationId = cs.IdStation
		,@VpCodeOfReference = cs.CodeOfReference
		,@StationType = cs.StationType
		,@StationName= IIF(cs.StationType = 1,'HUB ','') + cs.StationName 	
	    ,@StationDetail = IIF(cs.StationType = 1,
		 --CONVERT(VARCHAR(50),HBL.IdHubLogistic)
		'',CONVERT(VARCHAR(50),CONVERT(VARCHAR(50),VPC.CodeOfReference) + ' ' + VPC.Address))	
          ,@Country = cs.CountryId
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
			   ,@VpCodeOfReference = -1
	ELSE
        IF @StationType = 1 
           AND @Country = 'GT'
        BEGIN
            SET @VpCodeOfReference = 999
        END
        IF @StationType = 1 
           AND @Country = 'HN'
        BEGIN
            SET @VpCodeOfReference = 341648 --Por definir
        END

	SELECT @VpCodeOfReference VpCodeOfReference, @StationId StationId,@StationName StationName,@StationDetail StationDetail
 	   
END
