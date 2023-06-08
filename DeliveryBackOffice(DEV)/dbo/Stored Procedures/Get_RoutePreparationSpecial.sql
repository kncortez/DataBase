-- Author:		<Eduardo, López>
-- Create date: <2023-05-30>
-- Description:	<Obtener guías relacionadas a una ruta especial espeficada>

CREATE PROCEDURE [dbo].[Get_RoutePreparationSpecial]
	@IdRoute INT,
	@Date DATE

AS

--IF EXISTS (SELECT TOP 1 1 FROM RoutePreparation WHERE CatRouteId = @IdRoute AND DateRoutePreparation = @Date)
	DECLARE @IdHeader INT;

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
	DROP TABLE #listGuides;
BEGIN

	SET @IdHeader = (SELECT TOP 1 IDTSERoutePreparationHeader FROM TSERoutePreparationHeader WITH(NOLOCK) 
	WHERE IdCatRoute = @IdRoute AND RowStatus = 1);


      SELECT
	  ROW_NUMBER() OVER (ORDER BY trd.GuideNumber) AS Line,
	  (trd.GuideSerie+ CAST(trd.GuideNumber AS VARCHAR)) AS Guide, 
	  dor.Receiver_Department AS ProvinceDescription, 
	  dor.Receiver_Town AS TownshipName, 
	  --crc.ClusterDescription,
	  dor.Receiver_FirstName AS ClusterDescription,
	  dor.Receiver_Address,
	  COUNT(dop.GuideNumber) AS TotalPieces
	  ,(
		SELECT COUNT(DOP2.GuidePiece) FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP2 WITH(NOLOCK) 
		WHERE 
		DOP2.GuideNumber = trd.GuideNumber
		AND 
		DOP2.StatusOrderId = 2 --guías que ya fueron recolectadas	
	  ) ScannedPiecesTotal,
	   CONVERT(VARCHAR(50),(
		SELECT COUNT(DOP2.GuidePiece) FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP2 WITH(NOLOCK) 
		WHERE 
		DOP2.GuideNumber = trd.GuideNumber
		AND 
		DOP2.StatusOrderId = 2 --guías que ya fueron recolectadas	
	  )) + '/' + CONVERT(VARCHAR(50),COUNT(dop.GuideNumber)) TotalDescription
	  FROM dbo.CatRoute ctr	 
	  INNER JOIN dbo.TSERoutePreparationHeader trp WITH(NOLOCK)
	  ON ctr.IdRoute = trp.IdCatRoute
	  INNER JOIN dbo.CatRouteCluster crc WITH(NOLOCK)
	  ON trp.IdCatRouteCluster = crc.IdCatRouteCluster
	  INNER JOIN dbo.TSERoutePreparationDetail trd WITH(NOLOCK)
	  ON trp.IDTSERoutePreparationHeader = trd.TSERoutePreparationHeaderID
	  AND trd.RowStatus = 1
	  INNER JOIN dbo.DeliveryOrder dor WITH(NOLOCK)
	  ON trd.GuideSerie = dor.Guide_Serie AND trd.GuideNumber = dor.Guide_Number
	  INNER JOIN dbo.DeliveryOrderPiece dop WITH(NOLOCK)
	  ON dor.Guide_Serie = dop.GuideSerie AND dor.Guide_Number = dop.GuideNumber
	  WHERE ctr.IdRoute = @IdRoute --775
	  AND HasFirstPickupProcess = 0
	  AND HasFirstArrivalProcess = 0
	  AND HasFirstDispatchProcess = 0
	  AND HasFirstDeliveryProccess = 0
	  AND HasLastDeliveryProccess = 0
	  GROUP BY trd.GuideSerie,trd.GuideNumber,dor.Receiver_Town, dor.Receiver_Department,dor.Receiver_FirstName,crc.ClusterDescription,dor.Receiver_Address
	  HAVING COUNT(dop.GuideNumber) > 1;

		SELECT
		tsd.GuideSerie
	   ,tsd.GuideNumber
	   INTO #listGuides
			FROM TSERoutePreparationDetail tsd WITH(NOLOCK)
			WHERE tsd.TSERoutePreparationHeaderID = @IdHeader
			AND tsd.RowStatus = 1
			--SELECT *from #listGuides;

		SELECT COUNT(lgs.GuideNumber) AS TotalGuides FROM #listGuides lgs;

	  	SELECT COUNT(dyop.GuideNumber) AS TotalPieces FROM DeliveryOrderPiece dyop WITH(NOLOCK)
							INNER JOIN #listGuides lsg
							ON dyop.GuideSerie = lsg.GuideSerie
							AND dyop.GuideNumber = lsg.GuideNumber;

		SELECT UnitNumber FROM TSERoutePreparationHeader tsh WITH(NOLOCK)
			 INNER JOIN CatVehicle ctv
			 ON tsh.IdCatVehicle = ctv.IdVehicle
			 WHERE IDTSERoutePreparationHeader = @IdHeader AND tsh.RowStatus = 1;

		SELECT TSECustomsMark
			FROM TSERoutePreparationHeader WITH(NOLOCK)
			WHERE IDTSERoutePreparationHeader = @IdHeader AND RowStatus = 1;
				
							

END