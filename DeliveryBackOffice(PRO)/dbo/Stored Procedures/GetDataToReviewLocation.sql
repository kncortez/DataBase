

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-02-22>
-- Description:	< obtiene los intentos de entrega realizados en un periodo de tiempo para revisión de ubicaciones >
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2022-08-05>
-- Description:	< Mejora de rendimiento de proceso de obtención de datos historicos >
-- =============================================
CREATE PROCEDURE [dbo].[GetDataToReviewLocation]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN

	
	IF OBJECT_ID('tempdb.dbo.#DeliveryAttemptByDateRange', 'U') IS NOT NULL DROP TABLE #DeliveryAttemptByDateRange;
	IF OBJECT_ID('tempdb.dbo.#AuxGuideData', 'U') IS NOT NULL DROP TABLE #AuxGuideData;
	IF OBJECT_ID('tempdb.dbo.#AuxGuideDataClean', 'U') IS NOT NULL DROP TABLE #AuxGuideDataClean;
	IF OBJECT_ID('tempdb.dbo.#HistoricLocationByPhone', 'U') IS NOT NULL DROP TABLE #HistoricLocationByPhone;
	IF OBJECT_ID('tempdb.dbo.#HistoricLocationBySocialSecurityNumber', 'U') IS NOT NULL DROP TABLE #HistoricLocationBySocialSecurityNumber;

	IF(@EndDate IS NULL)
	BEGIN
		SET @EndDate = GETDATE()
	END

	IF(@StartDate IS NULL)
	BEGIN
		SET @StartDate = CAST(@EndDate AS DATE)
	END
	-- Intentos de entrega para la fecha actual
	SELECT
		DISTINCT
			DA.Guide_Serie 'GuideSerie'
			,DA.Guide_Number 'GuideNumber'
			,DA.Latitude
			,DA.Longitude
			,DA.Accuracy
	INTO #DeliveryAttemptByDateRange
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
	WHERE
		DA.Delivered = 1
		AND
		DA.Date_Created BETWEEN @StartDate AND @EndDate
		AND
		LTRIM(RTRIM(ISNULL(DA.Latitude,''))) != ''
		AND
		LTRIM(RTRIM(ISNULL(DA.Longitude,''))) != ''

	CREATE NONCLUSTERED INDEX Temp_TopDeliveryAttempt ON #DeliveryAttemptByDateRange (GuideSerie, GuideNumber)

	-- Datos de guías
	SELECT DISTINCT
		DO1.Guide_Serie,
		DO1.Guide_Number,
		DO1.Receiver_Phone,
		DO1.Receiver_SocialSecurity_ID,
		DO1.Receiver_Address
	INTO #AuxGuideData
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO1 WITH(NOLOCK)
		INNER JOIN
			#DeliveryAttemptByDateRange DA1
			ON
				DO1.Guide_Serie = DA1.GuideSerie
				AND
				DO1.Guide_Number = DA1.GuideNumber
				
				
	CREATE NONCLUSTERED INDEX Temp_guideDataByPhone ON #AuxGuideData (Receiver_Phone)
	CREATE NONCLUSTERED INDEX Temp_guideDataBySocialSecurityNumber ON #AuxGuideData (Receiver_SocialSecurity_ID)

	-- Copia de datos para procesamiento
	SELECT
		AGD.Guide_Serie,
		AGD.Guide_Number,
		AGD.Receiver_Address,
		AGD.Receiver_Phone,
		AGD.Receiver_SocialSecurity_ID
	INTO #AuxGuideDataClean
	FROM
		#AuxGuideData AGD

	CREATE NONCLUSTERED INDEX Temp_guideDataByGuide ON #AuxGuideDataClean (Guide_Serie, Guide_Number)

	-- Prelimpia de datos para busqueda de coincidencias en historico
	UPDATE
		#AuxGuideData
	SET
		Receiver_Phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Receiver_Phone,'+502',''),'(+502)',''),'(502)',''),'(',''),')',''),'-',''),' ','')

	-- Historico actual de datos por teléfono
	SELECT DISTINCT
		AGD.Guide_Serie,
		AGD.Guide_Number,
		LR.Accuracy,
		LR.[Address]
	INTO #HistoricLocationByPhone
	FROM
		[DeliveryBackOffice].[dbo].[LocationRecord] LR WITH(NOLOCK)
		INNER JOIN
			#AuxGuideData AGD
			ON
				AGD.Receiver_Phone LIKE '%'+LR.Phone+'%'
	WHERE
		LR.RowStatus = 1
		
	CREATE NONCLUSTERED INDEX Temp_LocationDataByPhoneGuide ON #HistoricLocationByPhone (Guide_Serie, Guide_Number)

	-- Historico actual de datos por número de seguridad social
	SELECT DISTINCT
		AGD.Guide_Serie,
		AGD.Guide_Number,
		LR.Accuracy,
		LR.[Address]
	INTO #HistoricLocationBySocialSecurityNumber
	FROM
		[DeliveryBackOffice].[dbo].[LocationRecord] LR WITH(NOLOCK)
		INNER JOIN
			#AuxGuideData AGD
			ON
				AGD.Receiver_SocialSecurity_ID = LR.SocialSecurityId
	WHERE
		LR.RowStatus = 1
		
	CREATE NONCLUSTERED INDEX Temp_LocationDataBySocialSecurityNumberGuide ON #HistoricLocationBySocialSecurityNumber (Guide_Serie, Guide_Number)

	-- Historico de ubicaciones bajo número de teléfono
	SELECT DISTINCT
		LTRIM(RTRIM(ISNULL(DO1.Receiver_Phone,''))) 'ReceiverPhone',
		DO1.Receiver_Address 'Address',
		DA1.Accuracy 'Accuracy',
		DA1.Latitude,
		DA1.Longitude
		,LR.Accuracy 'RegistryAccuracy'
		,LR.[Address] 'RegistryAddress'
		,0 'UpdateCandidate'
	FROM
		#AuxGuideDataClean DO1
		INNER JOIN
			#DeliveryAttemptByDateRange DA1
			ON
				DO1.Guide_Serie = DA1.GuideSerie
				AND
				DO1.Guide_Number = DA1.GuideNumber
		LEFT JOIN
			#HistoricLocationByPhone LR
			ON
				DO1.Guide_Serie = LR.Guide_Serie
				AND
				DO1.Guide_Number = LR.Guide_Number
	WHERE
		LTRIM(RTRIM(ISNULL(DO1.Receiver_Phone,''))) != ''

	---- Historico de ubicaciones bajo número de seguridad social
	SELECT DISTINCT
		DO1.Receiver_SocialSecurity_ID 'SocialSecurity'
		,DO1.Receiver_Address 'Address'
		,DA1.Accuracy 'Accuracy'
		,DA1.Latitude
		,DA1.Longitude
		,LR.Accuracy 'RegistryAccuracy'
		,LR.[Address] 'RegistryAddress'
		,0 'UpdateCandidate'
	FROM 
		#AuxGuideDataClean DO1
		INNER JOIN
			#DeliveryAttemptByDateRange DA1
			ON
				DO1.Guide_Serie = DA1.GuideSerie
				AND
				DO1.Guide_Number = DA1.GuideNumber
		LEFT JOIN
			#HistoricLocationBySocialSecurityNumber LR
			ON
				DO1.Guide_Serie = LR.Guide_Serie
				AND
				DO1.Guide_Number = LR.Guide_Number
	WHERE
		LTRIM(RTRIM(ISNULL(DO1.Receiver_SocialSecurity_ID,''))) != ''
	
	IF OBJECT_ID('tempdb.dbo.#DeliveryAttemptByDateRange', 'U') IS NOT NULL DROP TABLE #DeliveryAttemptByDateRange;
	IF OBJECT_ID('tempdb.dbo.#AuxGuideData', 'U') IS NOT NULL DROP TABLE #AuxGuideData;
	IF OBJECT_ID('tempdb.dbo.#AuxGuideDataClean', 'U') IS NOT NULL DROP TABLE #AuxGuideDataClean;
	IF OBJECT_ID('tempdb.dbo.#HistoricLocationByPhone', 'U') IS NOT NULL DROP TABLE #HistoricLocationByPhone;
	IF OBJECT_ID('tempdb.dbo.#HistoricLocationBySocialSecurityNumber', 'U') IS NOT NULL DROP TABLE #HistoricLocationBySocialSecurityNumber;
			
END
