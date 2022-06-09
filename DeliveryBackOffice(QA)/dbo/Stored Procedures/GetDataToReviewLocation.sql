

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-02-22>
-- Description:	< obtiene los intentos de entrega realizados en un periodo de tiempo para revisión de ubicaciones >
-- =============================================
CREATE PROCEDURE [dbo].[GetDataToReviewLocation]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN

	IF(@EndDate IS NULL)
	BEGIN
		SET @EndDate = GETDATE()
	END

	IF(@StartDate IS NULL)
	BEGIN
		SET @StartDate = CAST(@EndDate AS DATE)
	END

	-- Historico de ubicaciones bajo número de teléfono
	SELECT DISTINCT
		LTRIM(RTRIM(ISNULL(DO1.Receiver_Phone,''))) 'ReceiverPhone',
		DO1.Receiver_Address 'Address',
		DA1.Accuracy 'Accuracy',
		DA1.Latitude,
		DA1.Longitude
		,LR.Accuracy 'RegistryAccuracy'
		,LR.Address 'RegistryAddress'
		,0 'UpdateCandidate'
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO1 WITH(NOLOCK)
		JOIN
			[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA1 WITH(NOLOCK)
			ON
				DO1.Guide_Number = DA1.Guide_Number
				AND 
				DO1.Guide_Serie = DA1.Guide_Serie
		JOIN 
		(
			SELECT DISTINCT
				LTRIM(RTRIM(ISNULL(DO2.Receiver_Phone,''))) 'ReceiverPhone',
				MIN(CAST(DA2.Accuracy AS DECIMAL)) Accuracy
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO2 WITH(NOLOCK)
				JOIN
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA2 WITH(NOLOCK)
					ON 
						DO2.Guide_Number = DA2.Guide_Number
						AND 
						DO2.Guide_Serie = DA2.Guide_Serie
						AND 
						DA2.Accuracy IS NOT NULL
						AND 
						RTRIM(DA2.Accuracy) != ''
						AND
						DA2.Delivered = 1
						AND
						DA2.Date_Created >= @StartDate
						AND
						DA2.Date_Created <= @EndDate
			WHERE 
				DO2.Receiver_Phone IS NOT NULL
				AND 
				LTRIM(RTRIM(ISNULL(DO2.Receiver_Phone,''))) != ''
			GROUP BY DO2.Receiver_Phone
		) DA2
		ON 
			LTRIM(RTRIM(ISNULL(DO1.Receiver_Phone,''))) = DA2.ReceiverPhone
			AND 
			DA1.Accuracy = DA2.Accuracy
			AND
			DA1.Date_Created >= @StartDate
			AND
			DA1.Date_Created <= @EndDate
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[LocationRecord] LR
		ON
			REPLACE(REPLACE(REPLACE(REPLACE(DO1.Receiver_Phone,'(',''),')',''),'-',''),' ','') LIKE '%'+LR.Phone+'%'
			AND
			LR.RowStatus = 1

	-- Historico de ubicaciones bajo número de seguridad social
	SELECT DISTINCT
		DO1.Receiver_SocialSecurity_ID 'SocialSecurity'
		,DO1.Receiver_Address 'Address'
		,DA1.Accuracy 'Accuracy'
		,DA1.Latitude
		,DA1.Longitude
		,LR.Accuracy 'RegistryAccuracy'
		,LR.Address 'RegistryAddress'
		,0 'UpdateCandidate'
	FROM 
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO1 WITH (NOLOCK)
	JOIN 
		[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA1 WITH (NOLOCK)
		ON 
			DO1.Guide_Number = DA1.Guide_Number
			AND 
			DO1.Guide_Serie = DA1.Guide_Serie
	JOIN 
		(
			SELECT DISTINCT
				DO2.Receiver_SocialSecurity_ID
				,MIN(DA2.Accuracy) Accuracy
			FROM 
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO2 WITH (NOLOCK)
				JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA2 WITH (NOLOCK)
					ON 
						DO2.Guide_Number = DA2.Guide_Number
						AND
						DO2.Guide_Serie = DA2.Guide_Serie
						AND 
						DA2.Accuracy IS NOT NULL
						AND 
						RTRIM(DA2.Accuracy) != ''
				WHERE 
					DO2.Receiver_SocialSecurity_ID IS NOT NULL
					AND 
					RTRIM(DO2.Receiver_SocialSecurity_ID) != ''
					AND 
					DA2.Delivered = 1
					AND
					DA2.Date_Created >= @StartDate
					AND
					DA2.Date_Created <= @EndDate
			GROUP BY 
				DO2.Receiver_SocialSecurity_ID
		) DA2
		ON 
			DO1.Receiver_SocialSecurity_ID = DA2.Receiver_SocialSecurity_ID
			AND 
			DA1.Accuracy = DA2.Accuracy
			AND
			DA1.Date_Created >= @StartDate
			AND
			DA1.Date_Created <= @EndDate
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[LocationRecord] LR
		ON
			DO1.Receiver_SocialSecurity_ID = LR.SocialSecurityId
			AND
			LR.RowStatus = 1
			
END
