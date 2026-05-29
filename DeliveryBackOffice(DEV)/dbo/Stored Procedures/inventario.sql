CREATE procedure inventario

as begin

	WITH CTE_EstadosOrdenados AS (
		SELECT top 1
			  CS.Name                                   AS CLIENTE,
			  ord.ReceiverCountryId                     AS [PAIS],
			  ord.datecreated                           AS [FECHA DE CREACIÓN],
			  ord.Guide_Serie                           AS [SERIE DE GUIA],
			  ord.Guide_Number                          AS GUIA,
			  st.OrderDescription                       AS ESTADO,
			  (SELECT TOP 1 so4.OrderDescription FROM dbo.DeliveryOrderDetail dod4
			  INNER JOIN dbo.StatusOrder so4
			  ON so4.StatusOrderId = dod4.StatusOrderId
			  WHERE dod.Guide_Serie = dod4.Guide_Serie 
			  AND dod.Guide_Number = dod4.Guide_Number
			  ORDER BY dod4.DateCreated DESC) AS ULTIMO_ESTADO,
			  ISNULL(hbo.HubAbbreviation, dpo.Hub)      AS HUB_ORIGEN,
			  ISNULL(hbd.HubAbbreviation, dpd.Hub)      AS HUB_DESTINO,
			  CONVERT(DATE, DOD.DateCreatedInSystem)    AS FECHA_ULTIMO_ESTADO,
			  CONVERT(TIME, DOD.DateCreatedInSystem)    AS HORA_ULTIMO_ESTADO,
			  DATEDIFF(DAY, ord.DateCreated, GETDATE()) AS ANTIGUEDAD,
			  ct.StationName                            AS ESTACION,
			   ROW_NUMBER() OVER (
				   PARTITION BY DOD.Guide_Serie, DOD.Guide_Number
				   ORDER BY DOD.DateCreatedInSystem DESC
			  ) AS RN,
			  --cr.RegionName                             AS REGION,
			  ord.Pieces_Dry                            AS [PIEZAS SECAS],
			  ord.Pieces_Cold                           AS [PIEZAS FRIAS],

			  (SELECT TOP 1 dod2.DateCreated
			   FROM dbo.DeliveryOrderDetail dod2 WITH (NOLOCK)
			   WHERE dod2.Guide_Serie = DOD.Guide_Serie 
				 AND dod2.Guide_Number = DOD.Guide_Number
				 AND dod2.StatusOrderId = 11
			   ORDER BY dod2.DateCreated ASC) AS [FECHA 1r ARRIBO],
			   ord.IsLastMileReturn AS Devolución
		FROM dbo.DeliveryOrder ord WITH (NOLOCK)
		LEFT JOIN dbo.StatusOrder st WITH (NOLOCK)
			ON st.StatusOrderId = ord.StatusOrderId
		LEFT JOIN dbo.Customer CS WITH (NOLOCK)
			ON CS.IdCustomer = ord.IdCustomer
		LEFT JOIN dbo.HubLogistics hbo WITH (NOLOCK)
			ON hbo.IdHubLogistic = ord.HubOriginId
		LEFT JOIN dbo.HubLogistics hbd WITH (NOLOCK)
			ON hbd.IdHubLogistic = ord.HubDestinationId
		LEFT JOIN dbo.DumpServiceCoverage dpo WITH (NOLOCK)
			ON dpo.IdSettlement = ord.SenderIdSettlement
		LEFT JOIN dbo.DumpServiceCoverage dpd WITH (NOLOCK)
			ON dpd.IdSettlement = ord.ReceiverIdSettlement
		LEFT JOIN dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
			ON DOD.Guide_Serie = ord.Guide_Serie
			AND DOD.Guide_Number = ord.Guide_Number
			--AND DOD.StatusOrderId = ord.StatusOrderId
		LEFT JOIN dbo.CatStation ct WITH (NOLOCK)
			ON ct.IdStation = DOD.StationId
		LEFT JOIN dbo.HubByRegion hr WITH (NOLOCK)
			ON hr.HubLogisticId = ord.HubOriginId
		LEFT JOIN dbo.CatRegion cr WITH (NOLOCK)
			ON cr.IdCatRegion = hr.RegionId
		WHERE st.StatusOrderId IN (
			  2,3,4,6,8,10,11,13,16,17,18,19,20,26,28,29,31,32,
			  43,44,45,46,48,50,51,54,55,56
		)
		  AND ord.ReceiverCountryId = 'GT'
		  AND ord.DateCreated > '2026-01-01'
		  --AND ord.Guide_Number in (26040322)
	)

	SELECT 
		  OD.*,
		  CASE 
			WHEN OD.ANTIGUEDAD BETWEEN 0 AND 5   THEN '0-5 días'
			WHEN OD.ANTIGUEDAD BETWEEN 6 AND 10  THEN '6-10 días'
			WHEN OD.ANTIGUEDAD BETWEEN 11 AND 20 THEN '11-20 días'
			WHEN OD.ANTIGUEDAD BETWEEN 21 AND 40 THEN '21-40 días'
			WHEN OD.ANTIGUEDAD BETWEEN 41 AND 60 THEN '41-60 días'
			WHEN OD.ANTIGUEDAD BETWEEN 61 AND 90 THEN '61-90 días'
			ELSE '90+ días'
		  END AS Cat_Antiguedad
	FROM CTE_EstadosOrdenados OD
	WHERE RN = 1;


end