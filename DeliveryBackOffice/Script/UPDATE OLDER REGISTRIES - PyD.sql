
IF OBJECT_ID('tempdb.dbo.#GuidesToUpdatePyD', 'U') IS NOT NULL 
	DROP TABLE #GuidesToUpdatePyD;
		
CREATE TABLE #GuidesToUpdatePyD  (
	GuideSerie NVARCHAR(2)
	,GuideNumber INT
	,BilledWeight DECIMAL(12,2)
);

CREATE NONCLUSTERED INDEX TempGuidesToUpdate_Index ON #GuidesToUpdatePyD (GuideSerie, GuideNumber)

INSERT INTO #GuidesToUpdatePyD
(GuideSerie, GuideNumber, BilledWeight)
SELECT
	GWS.Guide_Serie
	,GWS.Guide_Number
	,GWS.CheckedWeight
FROM
	(
		SELECT
			DO.Guide_Serie
			,DO.Guide_Number
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
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
				ON
					DO.Guide_Serie = DOP.GuideSerie
					AND
					DO.Guide_Number = DOP.GuideNumber
		WHERE
			DO.BilledWeight IS NULL
		GROUP BY
			DO.Guide_Serie
			,DO.Guide_Number
	) GWS
WHERE
	ISNULL(GWS.CheckedWeight, 0) > 0

	/*

SELECT
	*
FROM
	#GuidesToUpdatePyD

	*/

-- Actualizar con datos que mando el cliente
UPDATE
	DO
SET
	DO.BilledWeight = GTUPyD.BilledWeight
FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	JOIN
		#GuidesToUpdatePyD GTUPyD
		ON
			DO.Guide_Serie = GTUPyD.GuideSerie
			AND
			DO.Guide_Number = GTUPyD.GuideNumber
			AND
			ISNULL(GTUPyD.BilledWeight, 0) > 0
WHERE
	ISNULL(DO.BilledWeight,0) = 0


IF OBJECT_ID('tempdb.dbo.#GuidesToUpdateEXC', 'U') IS NOT NULL 
	DROP TABLE #GuidesToUpdateEXC;
		
