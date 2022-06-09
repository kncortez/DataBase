-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <2021-10-23>
-- Description:	<Obtener estaciones por usuario>
-- =============================================
--EXEC [dbo].[GetStationByUser]  @IdUser = 100051,@UserName = 'carlos.cano'

CREATE PROCEDURE [dbo].[GetStationByUser]    
    @IdUser BIGINT,
	@UserName NVARCHAR(50)
AS
BEGIN
	SELECT 
	CST.IdStation IdStation ,IIF(CST.StationType = 1,'HUB ','') + CST.StationName StationName 	
	,IIF(CST.StationType = 1,
	--CONVERT(VARCHAR(50),HBL.IdHubLogistic)
	''
	,
	CONVERT(VARCHAR(50),CONVERT(VARCHAR(50),VPC.CodeOfReference) + ' ' + VPC.Address)	
	)	Detail	
	FROM DeliveryBackOffice.dbo.InternalUser INU
	JOIN DeliveryBackOffice.dbo.RolByUserBySystem RUS 
	ON INU.RegisterUserID = RUS.RusIdUser
	JOIN DeliveryBackOffice.dbo.CatStation CST
	ON CST.IdStation = RUS.StationId
	LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HBL
	ON HBL.IdHubLogistic = CST.HubLogisticId AND CST.StationType = 1
	LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
	ON VPC.CodeOfReference = CST.CodeOfReference AND CST.StationType = 2
	WHERE INU.IdUser = @IdUser 
	AND INU.Username = @UserName
	
END
