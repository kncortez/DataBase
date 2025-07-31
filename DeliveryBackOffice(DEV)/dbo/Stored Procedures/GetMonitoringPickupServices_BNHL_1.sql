-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-04-07>
-- Description:	<Obtiene información para Form Monitoreo de Servicios de Recolección>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-08-27>
-- Description:	<Se cambia la dirección y la fecha de servicio por el de recolección>
-- =============================================
CREATE PROCEDURE [dbo].[GetMonitoringPickupServices_BNHL]
	-- Add the parameters for the stored procedure here
	@CustomerId INT = -1,
	@DateStart DATE = '2022-01-07',
	@DateEnd DATE = '2022-04-07',
	@Phone NVARCHAR(50) = '-1'
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

    DECLARE @PhoneNew NVARCHAR(52) =IIF(@Phone = '-1','-1',CONCAT('%',REPLACE(@Phone,'-',''),'%'))

	SELECT DISTINCT
		IdServiceManagement ServiceId
	   ,sp.SenderName Customer  
	   ,vpc.DescriptionOfClient VisitPoint
	   ,p.ProvinceName Department
	   ,ts.TownshipName Town
	   ,sp.AddressPickup Address
	   ,css.Name Status
	   ,IIF(sp.IsScheduled IS NULL OR sp.IsScheduled = 0, 'A demanda', 'Programada') TypeService
	   --,FORMAT(sp.StartDate,'dd/MM/yyyy HH:mm:ss') DateCreated
	  -- ,FORMAT(sp.EndDate,'dd/MM/yyyy HH:mm:ss') EndDate
	   ,ISNULL(IIF(hl.HubAbbreviation IS NOT NULL, hl.HubAbbreviation, hlbts.HubName), BHC.HubAbbreviation) [OriginHub] 
	   , cr.CodeRoute  [RouteName]
	   , CONCAT(sr.First_Name, ' ', sr.Last_Name) [CourierName]
	   ,cv.UnitNumber  [UnitNumber]
	   , sp.SenderName [SenderName]
	   , sp.SenderPhone [SenderPhone]
	   , CAST(sm.DateCreated AS DATE) [DateCreated]
	   ,CAST(sm.DateCreated AS TIME(0))	[TimeCreated]
	   ,CAST(sp.StartDate AS DATE) [StartDate]
	   ,CAST(sp.StartDate AS TIME(0))	[TimeStartDate]
	   ,ra.IdRouteAssigment [IdRouteAssigment] 
	   ,(
                SELECT SUM(ISNULL(dor.Pieces_Cold, 0)) + SUM(ISNULL(dor.Pieces_Dry, 0)) 
                FROM [dbo].[DeliveryOrderPaymentDetail]                  AS dop WITH (NOLOCK)
                    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] AS dor WITH (NOLOCK)
                        ON dor.Guide_Number = dop.GuideNumber
                           AND dor.Guide_Serie = dop.GuideSerie
                WHERE dop.IdHeaderRecolection = sp.SchedulePickupId
	   ) AS [TotalPieces]
	   ,ctv.Name [TypeVehicleName]
	FROM ServiceManagement sm WITH(NOLOCK)
	INNER JOIN SchedulePickup sp WITH(NOLOCK)
		ON sp.SchedulePickupId = sm.IdSchedulePickup
	INNER JOIN VisitPointClient vpc WITH(NOLOCK)
		ON vpc.CodeOfReference = sp.SenderId
	INNER JOIN CatServiceStatus css WITH(NOLOCK)
		ON css.IdServiceStatus = sm.ServiceStatusId
	INNER JOIN Customer cu WITH(NOLOCK)
		ON cu.IdCustomer = vpc.CustomerID
	LEFT JOIN CatSystem cs WITH(NOLOCK)
		ON cs.SysIdSystem = sp.IdSourcePlataform
	LEFT JOIN Township ts WITH(NOLOCK)
		ON ts.IdTownship = sp.TownshipId
	LEFT JOIN Province p WITH(NOLOCK)
		ON ts.IdProvince = p.IdProvince
	LEFT JOIN [DeliveryBackOffice].dbo.[HubLogistics]        hl WITH (NOLOCK)
        ON hl.IdHubLogistic = sp.IdHubLogistics
    LEFT JOIN [DeliveryBackOffice].dbo.[HubByRegion]         hbr WITH (NOLOCK)
        ON hl.IdHubLogistic = hbr.HubLogisticId
	LEFT JOIN
            (
                SELECT tbhl.IdTownship
                     , hl.HubAbbreviation  HubName -- COLOCAR ABREVIATURA DE HUB CRAS
                     , cre.RegionName
                FROM [DeliveryBackOffice].dbo.TownshipByHubLogistic    AS tbhl WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].HubLogistics AS hl WITH (NOLOCK)
                        ON tbhl.IdHublogistic = hl.IdHubLogistic
                    INNER JOIN [DeliveryBackOffice].dbo.[HubByRegion]  hbr WITH (NOLOCK)
                        ON hl.IdHubLogistic = hbr.HubLogisticId
                    INNER JOIN [DeliveryBackOffice].dbo.[CatRegion]    cre WITH (NOLOCK)
                        ON cre.IdCatRegion = hbr.RegionId
                WHERE tbhl.StatusTownshipHub = 1
                      AND hl.HubStatus = 1
            )                                                        AS hlbts
                ON hlbts.IdTownship = sp.TownshipId
	LEFT JOIN [DeliveryBackOffice].dbo.[SenderReceiver]      sr WITH (NOLOCK)
                ON sr.ID = sm.IdPuCourrier
			LEFT JOIN dbo.HubLogistics BHC ON BHC.IdHubLogistic = SR.HubLogisticId
	 LEFT JOIN [DeliveryBackOffice].dbo.RouteAssigment        ra WITH (NOLOCK)
                ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
            LEFT JOIN [DeliveryBackOffice].dbo.[CatVehicle]          cv WITH (NOLOCK)
                ON cv.IdVehicle = ra.IdVehicle
	 LEFT JOIN [DeliveryBackOffice].dbo.[CatRoute]            cr WITH (NOLOCK)
                ON cr.IdRoute = ra.IdRoute
	 LEFT JOIN [DeliveryBackOffice].dbo.CatTypeVehicle        ctv WITH (NOLOCK)
                ON cv.IdTypeVehicle = ctv.IdTypeVehicle
	 
	WHERE (cu.IdCustomer = @CustomerId
	OR @CustomerId = -1)
	AND (REPLACE(sp.SenderPhone, '-', '') LIKE @PhoneNew
	OR REPLACE(vpc.Phone, '-', '') LIKE @PhoneNew
	OR REPLACE(cu.CustomerPhone, '-', '') LIKE @PhoneNew
	OR @PhoneNew = '-1')
	AND CAST(sp.StartDate AS DATE) >= @DateStart
    AND CAST(sp.EndDate AS DATE) <= @DateEnd
END