
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-05-21>
-- Description:	<Obtiene todos los destinos frecuentes configurados de un punto servicio>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetDestiniesbyVisitPointID]
	-- Add the parameters for the stored procedure here
	@IdVisitPoint AS INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT vpd.[IdVPSource], 
		   vpd.[IDVPDestiny], 
		  --'[ ' + cast(vpcd.CodeOfReference as varchar) + ' ] - ' +  vpcd.DescriptionOfClient [VPName],
		   vpcd.DescriptionOfClient [VPName],
		   vpcd.BranchCode   [BranchCode],
		   vpcd.Address      [Address],
		   twn.TownshipName  [TownShip],
		   prv.ProvinceName  [Province],
		   vpd.[IsGuard], 
		   vpd.[IsTransit], 
		   vpd.[IsDefault],
		   vpd.RowStatus
	FROM dbo.VisitPointDestination vpd
	JOIN dbo.VisitPointClient vpcd ON vpd.IDVPDestiny = vpcd.CodeOfReference
	LEFT JOIN dbo.Township twn ON vpcd.IdTownship = twn.IdTownship
	LEFT JOIN dbo.Province prv ON twn.IdProvince = prv.IdProvince
	WHERE vpd.IdVPSource = @IdVisitPoint
	AND vpd.RowStatus = 'TRUE'
END
