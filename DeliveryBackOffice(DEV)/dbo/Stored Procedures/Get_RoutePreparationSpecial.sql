-- Author:		<Eduardo, López>
-- Create date: <2023-05-30>
-- Description:	<Obtener guías relacionadas a una ruta especial espeficada>

CREATE PROCEDURE Get_RoutePreparationSpecial
	@IdRoute INT,
	@Date DATE

AS

--IF EXISTS (SELECT TOP 1 1 FROM RoutePreparation WHERE CatRouteId = @IdRoute AND DateRoutePreparation = @Date)
	DECLARE @IdHeader INT;

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
	DROP TABLE #listGuides;
BEGIN
	/*SET @IdHeader = (SELECT TOP 1 tsed.TSERoutePreparationHeaderID FROM TSERoutePreparationHeader tseh
						INNER JOIN TSERoutePreparationDetail tsed
						ON tseh.IDTSERoutePreparationHeader = tsed.TSERoutePreparationHeaderID);*/

	SET @IdHeader = (SELECT TOP 1 IDTSERoutePreparationHeader FROM TSERoutePreparationHeader 
	WHERE IdCatRoute = @IdRoute 
	AND Cast(DateCreated AS Date) = @Date AND RowStatus = 1);


      SELECT
	  ROW_NUMBER() OVER (ORDER BY trd.GuideNumber) AS Line,
	  (trd.GuideSerie+ CAST(trd.GuideNumber AS VARCHAR)) AS Guide, 
	  pvc.ProvinceDescription, 
	  tws.TownshipName, 
	  crc.ClusterDescription,
	  dor.Receiver_Address,
	  COUNT(dop.GuideNumber) AS TotalPieces
	  FROM CatRoute ctr
	  INNER JOIN Township tws
	  ON ctr.IdTownship = tws.IdTownship
	  INNER JOIN Province pvc
	  ON tws.IdProvince = pvc.IdProvince
	  INNER JOIN TSERoutePreparationHeader trp
	  ON ctr.IdRoute = trp.IdCatRoute
	  INNER JOIN CatRouteCluster crc
	  ON trp.IdCatRouteCluster = crc.IdCatRouteCluster
	  INNER JOIN TSERoutePreparationDetail trd
	  ON trp.IDTSERoutePreparationHeader = trd.TSERoutePreparationHeaderID
	  INNER JOIN DeliveryOrder dor
	  ON trd.GuideSerie = dor.Guide_Serie AND trd.GuideNumber = dor.Guide_Number
	  INNER JOIN DeliveryOrderPiece dop
	  ON dor.Guide_Serie = dop.GuideSerie AND dor.Guide_Number = dop.GuideNumber
	  WHERE ctr.IdRoute = @IdRoute --775
	  AND HasFirstPickupProcess = 1--0
	  GROUP BY trd.GuideSerie,trd.GuideNumber,pvc.ProvinceDescription,tws.TownshipName,crc.ClusterDescription,dor.Receiver_Address
	  HAVING COUNT(dop.GuideNumber) > 1;

		SELECT
		tsd.GuideSerie
	   ,tsd.GuideNumber
	   INTO #listGuides
			FROM TSERoutePreparationDetail tsd
			WHERE TSERoutePreparationHeaderID = @IdHeader--29
			--SELECT *from #listGuides;

		SELECT COUNT(lgs.GuideNumber) AS TotalGuides FROM #listGuides lgs;

	  	SELECT COUNT(dyop.GuideNumber) AS TotalPieces FROM DeliveryOrderPiece dyop
							INNER JOIN #listGuides lsg
							ON dyop.GuideSerie = lsg.GuideSerie
							AND dyop.GuideNumber = lsg.GuideNumber;

		SELECT UnitNumber FROM TSERoutePreparationHeader tsh
			 INNER JOIN CatVehicle ctv
			 ON tsh.IdCatVehicle = ctv.IdVehicle
			 WHERE IDTSERoutePreparationHeader = @IdHeader;

		SELECT TSECustomsMark 
			FROM TSERoutePreparationHeader
			WHERE IDTSERoutePreparationHeader = @IdHeader;
				
							

END