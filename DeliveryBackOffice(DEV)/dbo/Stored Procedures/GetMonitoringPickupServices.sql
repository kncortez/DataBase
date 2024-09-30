-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-04-07>
-- Description:	<Obtiene información para Form Monitoreo de Servicios de Recolección>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-06-06>
-- Description: <Se agrego filtro por pais, por defecto GT>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-08-27>
-- Description:	<Se Agregan campos a la consulta y el nuevo filtro por Hub>
-- =============================================
CREATE PROCEDURE [dbo].[GetMonitoringPickupServices]
	-- Add the parameters for the stored procedure here
	@CustomerId INT = -1,
	@DateStart DATE = '2022-01-07',
	@DateEnd DATE = '2022-04-07',
	@Phone NVARCHAR(50) = '-1',
    @IdCountry VARCHAR(2) = 'GT',
	@HubId INT = -1
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

    DECLARE @PhoneNew NVARCHAR(52) =IIF(@Phone = '-1','-1',CONCAT('%',REPLACE(@Phone,'-',''),'%'))

	SELECT DISTINCT
		IdServiceManagement AS [ServiceId]
	   ,sp.SenderName AS [Customer]  
	   ,vpc.DescriptionOfClient AS [VisitPoint]
	   ,p.ProvinceName AS [Department]
	   ,ts.TownshipName AS [Town]
	   ,sp.AddressPickup AS [Address]
	   ,css.Name AS [Status]
	   ,IIF(sp.IsScheduled IS NULL OR sp.IsScheduled = 0, 'A demanda', 'Programada') AS [TypeService]
	   ,ISNULL(IIF(hl.HubAbbreviation IS NOT NULL, hl.HubAbbreviation, hlbts.HubName), BHC.HubAbbreviation) AS [OriginHub] 
	   , cr.CodeRoute  AS [RouteName]
	   , CONCAT(sr.First_Name, ' ', sr.Last_Name) AS [CourierName]
	   ,cv.UnitNumber AS [UnitNumber]
	   , sp.SenderName AS [SenderName]
	   , sp.SenderPhone AS [SenderPhone]
	   , CAST(sm.DateCreated AS DATE) AS [DateCreated]
	   ,CAST(sm.DateCreated AS TIME(0))	AS [TimeCreated]
	   ,CAST(sp.StartDate AS DATE) AS [StartDate]
	   ,CAST(sp.StartDate AS TIME(0)) AS [TimeStartDate]
	   ,ra.IdRouteAssigment AS [IdRouteAssigment] 
	   ,(
                SELECT SUM(ISNULL(dor.Pieces_Cold, 0)) + SUM(ISNULL(dor.Pieces_Dry, 0)) 
                FROM [dbo].[DeliveryOrderPaymentDetail]                  AS dop WITH (NOLOCK)
                    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] AS dor WITH (NOLOCK)
                        ON dor.Guide_Number = dop.GuideNumber
                           AND dor.Guide_Serie = dop.GuideSerie
                WHERE dop.IdHeaderRecolection = sp.SchedulePickupId
	   ) AS [TotalPieces]
	   ,ctv.Name AS [TypeVehicleName]
	FROM [DeliveryBackOffice].[dbo].ServiceManagement sm WITH(NOLOCK)
	INNER JOIN [DeliveryBackOffice].[dbo].SchedulePickup sp WITH(NOLOCK)
		ON sp.SchedulePickupId = sm.IdSchedulePickup
	INNER JOIN [DeliveryBackOffice].[dbo].VisitPointClient vpc WITH(NOLOCK)
		ON vpc.CodeOfReference = sp.SenderId
	INNER JOIN [DeliveryBackOffice].[dbo].CatServiceStatus css WITH(NOLOCK)
		ON css.IdServiceStatus = sm.ServiceStatusId
	INNER JOIN [DeliveryBackOffice].[dbo].Customer cu WITH(NOLOCK)
		ON cu.IdCustomer = vpc.CustomerID
	LEFT JOIN [DeliveryBackOffice].[dbo].CatSystem cs WITH(NOLOCK)
		ON cs.SysIdSystem = sp.IdSourcePlataform
	LEFT JOIN [DeliveryBackOffice].[dbo].Township ts WITH(NOLOCK)
		ON ts.IdTownship = sp.TownshipId
	LEFT JOIN [DeliveryBackOffice].[dbo].Province p WITH(NOLOCK)
		ON ts.IdProvince = p.IdProvince
	LEFT JOIN [DeliveryBackOffice].dbo.[HubLogistics] hl WITH (NOLOCK)
        ON hl.IdHubLogistic = sp.IdHubLogistics
    LEFT JOIN [DeliveryBackOffice].dbo.[HubByRegion] hbr WITH (NOLOCK)
        ON hl.IdHubLogistic = hbr.HubLogisticId
	--LEFT JOIN
 --           (
 --               SELECT tbhl.IdTownship
	--				,hl.IdHubLogistic
 --                    , hl.HubAbbreviation  HubName -- COLOCAR ABREVIATURA DE HUB CRAS
 --                    , cre.RegionName
 --               FROM [DeliveryBackOffice].dbo.TownshipByHubLogistic    AS tbhl WITH (NOLOCK)
 --                   INNER JOIN [DeliveryBackOffice].[dbo].HubLogistics AS hl WITH (NOLOCK)
 --                       ON tbhl.IdHublogistic = hl.IdHubLogistic
 --                   INNER JOIN [DeliveryBackOffice].dbo.[HubByRegion] AS hbr WITH (NOLOCK)
 --                       ON hl.IdHubLogistic = hbr.HubLogisticId
 --                   INNER JOIN [DeliveryBackOffice].dbo.[CatRegion] AS cre WITH (NOLOCK)
 --                       ON cre.IdCatRegion = hbr.RegionId
 --               WHERE tbhl.StatusTownshipHub = 1
 --                     AND hl.HubStatus = 1
 --           )                                                        AS hlbts
 --               ON hlbts.IdTownship = sp.TownshipId
  OUTER APPLY
        (
            SELECT TOP 1
                   A2.Hub HubName, --tbhl.IdTownship
				   A4.HubLogisticId,
				   A3.IdHubLogistic,
                   --, hl.HubAbbreviation  HubName -- COLOCAR ABREVIATURA DE HUB CRAS
                   A5.RegionName RegionName
            FROM DeliveryBackOffice.dbo.Township A1 WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.DumpServiceCoverage A2 WITH (NOLOCK)
                    ON A2.HeaderCode = A1.HeaderCode
                INNER JOIN DeliveryBackOffice.dbo.HubLogistics A3 WITH (NOLOCK)
                    ON A3.HubAbbreviation = A2.Hub
                LEFT JOIN DeliveryBackOffice.dbo.HubByRegion A4 WITH (NOLOCK)
                    ON A4.HubLogisticId = A3.IdHubLogistic
                LEFT JOIN DeliveryBackOffice.dbo.CatRegion A5
                    ON A4.RegionId = A5.IdCatRegion
            WHERE A1.IdTownship = sp.TownshipId
                  AND A2.RowStatus = 1
                  AND A3.HubStatus = 1
                  AND A4.RowStatus = 1
                  AND A5.RowStatus = 1
            ORDER BY A1.IdTownship ASC
        ) AS hlbts
	LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]      sr WITH (NOLOCK)
                ON sr.ID = sm.IdPuCourrier
	LEFT JOIN dbo.HubLogistics								BHC WITH (NOLOCK)
				ON BHC.IdHubLogistic = SR.HubLogisticId
	 LEFT JOIN [DeliveryBackOffice].dbo.RouteAssigment        ra WITH (NOLOCK)
                ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
		LEFT JOIN [DeliveryBackOffice].dbo.[CatVehicle]          cv WITH (NOLOCK)
                ON cv.IdVehicle = ra.IdVehicle
	 LEFT JOIN [DeliveryBackOffice].dbo.[CatRoute]            cr WITH (NOLOCK)
                ON cr.IdRoute = ra.IdRoute
	 LEFT JOIN [DeliveryBackOffice].dbo.CatTypeVehicle        ctv WITH (NOLOCK)
                ON cv.IdTypeVehicle = ctv.IdTypeVehicle
	WHERE (cu.IdCustomer = @CustomerId OR @CustomerId = -1)
		AND (REPLACE(sp.SenderPhone, '-', '') LIKE @PhoneNew OR REPLACE(vpc.Phone, '-', '') LIKE @PhoneNew OR REPLACE(cu.CustomerPhone, '-', '') LIKE @PhoneNew OR @PhoneNew = '-1')
		AND CAST(sp.StartDate AS DATE) >= @DateStart
    	AND CAST(sp.EndDate AS DATE) <= @DateEnd
		AND (ISNULL(IIF(hl.IdHubLogistic IS NOT NULL, hl.IdHubLogistic, hlbts.IdHubLogistic), BHC.IdHubLogistic) = @HubId 
		OR @HubId = -1)
		AND IIF(vpc.CountryId IS NULL,'GT', vpc.CountryId) = @IdCountry
END