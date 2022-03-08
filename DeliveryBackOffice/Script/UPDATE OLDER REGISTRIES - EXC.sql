
IF OBJECT_ID('tempdb.dbo.#GuidesToUpdateEXC', 'U') IS NOT NULL 
	DROP TABLE #GuidesToUpdateEXC;
		
DECLARE @EXCCustomerId INT = 0;
		
-- Buscar customer que representa Express Centers
SET @EXCCustomerId = (
	SELECT
		TOP 1
			Cu.IdCustomer
	FROM
		[DeliveryBackOffice].[dbo].[Customer] Cu
	WHERE
		Cu.Name = 'FD EXPRESS CENTER'
)

CREATE TABLE #GuidesToUpdateEXC  (
	GuideSerie NVARCHAR(2)
	,GuideNumber INT
	,BilledWeight DECIMAL(12,2)
);

CREATE NONCLUSTERED INDEX TempGuidesToUpdate_Index ON #GuidesToUpdateEXC (GuideSerie, GuideNumber)

INSERT INTO #GuidesToUpdateEXC
(GuideSerie, GuideNumber, BilledWeight)
SELECT
	DO.Guide_Serie
	,DO.Guide_Number
	,DO.BilledWeight
FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[VisitPointClient] VPCs WITH(NOLOCK)
		ON
			DO.Sender_ID = VPCs.CodeOfReference
			AND
			VPCs.StatusClient = 1
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
		ON
			ISNULL(DO.IdCustomer, VPCs.CustomerID) = Cu.IdCustomer
WHERE
	ISNULL(Cu.IdCustomer,0) = @EXCCustomerId -- EXPRESS CENTER
	AND
	DO.BilledWeight IS NULL
ORDER BY
	DO.Guide_Number DESC

/*

SELECT
	*
FROM
	#GuidesToUpdateEXC

*/

-- Actualizar con datos que mando el cliente
UPDATE
	DO
SET
	DO.BilledWeight = ISNULL(ISNULL(GWS.Weight,GWS.CheckedWeight),0)
FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	JOIN
		#GuidesToUpdateEXC GTUEXC
		ON
			DO.Guide_Serie = GTUEXC.GuideSerie
			AND
			DO.Guide_Number = GTUEXC.GuideNumber
	LEFT JOIN
		(
			SELECT
				DO.GuideSerie
				,DO.GuideNumber
				,SUM
				(
					CASE 
						WHEN DOP.[PieceWeight] IS NOT NULL AND DOP.[PiecePhysicalWeight] IS NULL THEN DOP.[PieceWeight]
						WHEN DOP.[PieceWeight] IS NULL AND DOP.[PiecePhysicalWeight] IS NOT NULL THEN DOP.[PiecePhysicalWeight]
						WHEN DOP.[PieceWeight] IS NULL AND DOP.[PiecePhysicalWeight] IS NULL THEN 0 
						WHEN DOP.[PieceWeight] > DOP.[PiecePhysicalWeight] THEN DOP.[PieceWeight]
						WHEN DOP.[PieceWeight] < DOP.[PiecePhysicalWeight] THEN DOP.[PiecePhysicalWeight]
						WHEN DOP.[PieceWeight] = DOP.[PiecePhysicalWeight] THEN DOP.[PiecePhysicalWeight]
					END
				) 'Weight'
				,SUM
				(
					CASE 
						WHEN DOP.[MassWeight] IS NOT NULL AND DOP.[volumetricWeight] IS NULL THEN DOP.[MassWeight]
						WHEN DOP.[MassWeight] IS NULL AND DOP.[volumetricWeight] IS NOT NULL THEN DOP.[volumetricWeight]
						WHEN DOP.[MassWeight] IS NULL AND DOP.[volumetricWeight] IS NULL THEN 0 
						WHEN DOP.[MassWeight] > DOP.[volumetricWeight] THEN DOP.[MassWeight]
						WHEN DOP.[MassWeight] < DOP.[volumetricWeight] THEN DOP.[volumetricWeight]
						WHEN DOP.[MassWeight] = DOP.[volumetricWeight] THEN DOP.[volumetricWeight]
					END
				) 'CheckedWeight'
			FROM
				#GuidesToUpdateEXC DO
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
					ON
						DO.GuideSerie = DOP.GuideSerie
						AND
						DO.GuideNumber = DOP.GuideNumber
			WHERE
				ISNULL(DO.BilledWeight,0) = 0
			GROUP BY
				DO.GuideSerie
				,DO.GuideNumber
		) GWS
		ON
			DO.Guide_Serie = GWS.GuideSerie
			AND
			DO.Guide_Number = GWS.GuideNumber
WHERE
	ISNULL(DO.BilledWeight,0) = 0


IF OBJECT_ID('tempdb.dbo.#GuidesToUpdateEXC', 'U') IS NOT NULL 
	DROP TABLE #GuidesToUpdateEXC;
		
