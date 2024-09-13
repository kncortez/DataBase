
-- =============================================
-- Author:		<Edelman>
-- Create date: <2024-08-04>
-- Description:	<Nuevo sp para encabezado de manifiesto de despacho a ruta>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_DispatchManifesttoDeliveryRoutesHeader]
		@IdManifest INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT TOP 1 
		dobs.ID, 
		dobs.Date_Dispatched, 
		dobs.Pieces_Dry_Dispatched, 
		dobs.Pieces_Cold_Dispatched, 
		dobs.Guides_Dispatched,
		sr.First_Name + ' ' + sr.Last_Name as Courier_Name,
		dobs.Route_Dispatched,
		CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Dispatched,
		ct.CodeRoute,
		cv.UnitNumber
	FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr  WITH(NOLOCK)
	ON sr.ID = dobs.ID_Courier
	INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH(NOLOCK)
	ON lbt.SSN_IdToken = dobs.User_Dispatched
	INNER JOIN [DeliveryBackOffice].[dbo].CatRoute ct WITH(NOLOCK)
	ON dobs.CatRouteId = ct.IdRoute
	INNER JOIN CatVehicle cv  WITH(NOLOCK)
	ON dobs.CatVehicleId = cv.IdVehicle
	WHERE dobs.ID = @IdManifest

END