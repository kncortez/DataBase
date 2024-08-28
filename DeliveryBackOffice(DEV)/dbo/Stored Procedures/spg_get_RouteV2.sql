
-- =============================================
-- Author:		<Cesar, Sazo>
-- Update date: <2021-12-30>
-- Description:	<Devuelve información sobre las rutas, piloto y unidad >
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-06-05>
-- Description: < Adicion de filtros por pais, por defect GT >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RouteV2] 
	@dateRoute AS DATE,
    @IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
	SELECT
		ctr.IdRoute
	   ,ctr.CodeRoute
	   ,ctr.[Description]
	   ,ctr.IdTownship
	   ,ts.TownshipName
	   ,ctr.IdTypeRoute
	   ,ctr.[Zone]
	   ,ctr.RowStatus
	   ,ctr.TokenCreated
	   ,ctr.DateCreated
	   ,ctr.TokenUpdated
	   ,ctr.DateUpdated
	   ,(SELECT TOP 1
				CONCAT(snr.First_Name, ' ', snr.Last_Name) NameCourier
			FROM [DeliveryBackOffice].[dbo].[RouteAssigment] rta
			INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] snr
				ON snr.ID = rta.IdCurrierMan
			WHERE rta.DateOfRoute = @dateRoute
			AND rta.IdRoute = ctr.IdRoute)
		NameCourier
	   ,(SELECT TOP 1
				cv.UnitNumber
			FROM [DeliveryBackOffice].[dbo].[RouteAssigment] rta
			INNER JOIN [DeliveryBackOffice].[dbo].[CatVehicle] cv
				ON cv.IdVehicle = rta.IdVehicle
			WHERE rta.DateOfRoute = @dateRoute
			AND rta.IdRoute = ctr.IdRoute)
		UnitNumber
	FROM [DeliveryBackOffice].[dbo].[CatRoute] ctr
	INNER JOIN [DeliveryBackOffice].[dbo].[Township] ts
		ON ts.IdTownship = ctr.IdTownship
        AND ts.TownshipStatus = 1
    INNER JOIN [DeliveryBackOffice].[dbo].[Province] pr
        ON pr.IdProvince = ts.IdProvince
        AND pr.ProvinceStatus = 1
	WHERE ctr.RowStatus = 1
		AND 
		(
			ctr.IdTypeRoute = (SELECT ctr.IdTypeRoute FROM CatTypeRoute ctr WHERE [Name] = 'Recolección')
			OR
			ctr.IdTypeRoute = (SELECT ctr.IdTypeRoute FROM CatTypeRoute ctr WHERE [Name] = 'Especiales')
		)
        AND IIF(pr.IdCountry IS NULL, 'GT', pr.IdCountry) = @IdCountry
	ORDER BY ctr.CodeRoute
END