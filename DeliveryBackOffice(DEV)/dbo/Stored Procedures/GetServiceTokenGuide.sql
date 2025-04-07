-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Obtiene datos basicos para actualizar la ubicación de un servicio de entrega para una guía en landing page.>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Cambio de flujo para retornar enlace de tracking y mejora de mensaje cuando guía esta en estado no actualizable.>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <2023-02-23>
-- Description:	< Manejo para decidir si mostrar mapa o no de acuerdo a radio máximo en base a georeferencia.>
-- Update date: <2023-02-27>
-- Description:	< Manejo de campos editables y textos dinamicos para landing page de incidencias.>
-- =============================================
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <2025-04-04>
-- Description:	<Se pasan todos los Json a entidades>
-- =============================================

CREATE PROCEDURE [dbo].[GetServiceTokenGuide]
	@GuideSerie NVARCHAR(2) = '',
	@GuideNumber INT = -1,
	@GuideToken NVARCHAR(50)
AS
BEGIN
	-- Variables de control de flujo
	DECLARE @IsDelivery AS BIT = 0;
	DECLARE @IsDeliveryOnRoute AS BIT = 0;
	DECLARE @IsPickup AS BIT = 0;
	DECLARE @IsVisitPoint AS BIT = 0;
	DECLARE @VisitPointExists AS BIT = 0;
	DECLARE @MaxDistance FLOAT = 7000; --Distancia en metros
	DECLARE @VPLatitude NVARCHAR(50)
	DECLARE @VPLongitude NVARCHAR(50)

	-- Variables de respuesta
	
	SET @IsDelivery = (
		SELECT TOP 1 (CASE WHEN SDFG.[IsDelivery] = 1 AND SDFG.IsInRoute = 0 THEN 1 ELSE 0 END) 
		FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
		WHERE SDFG.GuideToken = @GuideToken
		ORDER BY SDFG.DateCreated DESC
	);
	
	SET @IsDeliveryOnRoute = (
		SELECT TOP 1 (CASE WHEN SDFG.[IsDelivery] = 1 AND SDFG.IsInRoute = 1 THEN 1 ELSE 0 END) 
		FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
		WHERE SDFG.GuideToken = @GuideToken
		ORDER BY SDFG.DateCreated DESC
	);

	IF (@IsDeliveryOnRoute = 1)
	BEGIN

		BEGIN TRY
			DECLARE @GuideData TABLE
			(
				IdResult INT,
				receiverAddress NVARCHAR(150),
				serviceType NVARCHAR(25),
				updatedData BIT,
				DeliveryAttempt BIGINT,
				RoutePreparation INT,
				DeliverySettlement BIGINT,
				trackingForza NVARCHAR(150),
				Province NVARCHAR(50),
				Township NVARCHAR(50),
				deliveryType NVARCHAR(5)
			)
			
			INSERT INTO @GuideData
			(
				IdResult,
				receiverAddress,
				serviceType,
				updatedData,
				DeliveryAttempt,
				RoutePreparation,
				DeliverySettlement,
				trackingForza,
				Province,
				Township,
				deliveryType
			)

			SELECT 200 AS IdResult,
				   DO.Receiver_Address AS receiverAddress,
				   'DeliveryInRoute' AS serviceType,
				   IIF(SDFG.DateUsed IS NULL, 0, 1) AS updatedData,
				   DA.ID AS DeliveryAttempt,
				   RPD.IdRoutePreparation AS RoutePreparation,
				   RPD.DeliveryOrderBySettlementId AS DeliverySettlement,
				   'https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) + '/' AS trackingForza,
				   DO.Receiver_Department AS Province,
				   DO.Receiver_Town AS Township,
				   ISNULL(DO.TypeService, 'STD') AS deliveryType
			FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
				INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
					ON DO.Guide_Serie = SDFG.GuideSerie
					   AND DO.Guide_Number = SDFG.GuideNumber
				OUTER APPLY
			(
				SELECT TOP 1
					DAaux.ID,
					DAaux.Delivered,
					DAaux.ID_Incident,
					DAaux.ID_Proof
				FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DAaux WITH (NOLOCK)
				WHERE DAaux.Guide_Serie = DO.Guide_Serie
					  AND DAaux.Guide_Number = DO.Guide_Number
					  AND DAaux.Date_Created >= CAST(GETDATE() AS DATE)
				ORDER BY DAaux.Date_Created DESC
			) DA
				OUTER APPLY
			(
				SELECT TOP 1
					RP.IdRoutePreparation,
					DOBS.ID AS 'DeliveryOrderBySettlementId'
				FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH (NOLOCK)
						ON RPD.RoutePreparationId = RP.IdRoutePreparation
						   AND RP.DateRoutePreparation = CAST(GETDATE() AS DATE)
						   AND RP.RowStatus = 1
					INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
						ON RP.DeliveryOrderBySettlementId = DOBS.ID
				WHERE RPD.Guide_Serie = DO.Guide_Serie
					  AND RPD.Guide_Number = DO.Guide_Number
					  AND RPD.RowStatus = 1
				ORDER BY RP.DateCreated DESC
			) RPD
			WHERE SDFG.GuideToken = @GuideToken
				  AND DO.StatusOrderId IN ( 4, 18 ) -- En ruta, en ruta para devolución
				  AND SDFG.IsDelivery = 1
				  AND SDFG.IsInRoute = 1
				  AND SDFG.DateUsed IS NULL
			ORDER BY SDFG.DateCreated DESC

			IF EXISTS (SELECT TOP 1 1 FROM @GuideData)
			BEGIN
				SELECT IdResult, 
					   receiverAddress, 
					   serviceType,
					   updatedData,
					   DeliveryAttempt,
					   RoutePreparation,
					   DeliverySettlement,
					   trackingForza,
					   Province,
					   Township,
					   deliveryType
				FROM @GuideData
			END
			-- Guía en estado no modificable
			ELSE
			BEGIN
				SELECT 206 AS IdResult,
					   'DeliveryInRoute' AS serviceType,
					   'https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) AS trackingForza
				FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
					INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
						ON DO.Guide_Serie = SDFG.GuideSerie
						   AND DO.Guide_Number = SDFG.GuideNumber
				WHERE SDFG.GuideToken = @GuideToken
					  AND SDFG.IsDelivery = 1
					  AND SDFG.IsInRoute = 1
				ORDER BY SDFG.DateCreated DESC

			END
			-- Ultimo caso de error
			IF NOT EXISTS
			(
				SELECT TOP 1
					1
				FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
					INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
						ON DO.Guide_Serie = SDFG.GuideSerie
						   AND DO.Guide_Number = SDFG.GuideNumber
				WHERE SDFG.GuideToken = @GuideToken
					  AND SDFG.IsDelivery = 1
					  AND SDFG.IsInRoute = 1
			)
			BEGIN
				SELECT 204 AS IdResult,
					   'No se encontraron registros validos' AS [Message]	

			END
		END TRY
		BEGIN CATCH

				SELECT 500 AS IdResult,
						ERROR_MESSAGE() AS Error 

		END CATCH

	END
	ELSE IF (@IsDelivery = 1) -- Servicio es de entrega
	BEGIN
		BEGIN TRY

		IF EXISTS
		(
			SELECT TOP 1
				1
			FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
				INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
					ON DO.Guide_Serie = SDFG.GuideSerie
					   AND DO.Guide_Number = SDFG.GuideNumber
			WHERE SDFG.GuideToken = @GuideToken
				  AND DO.StatusOrderId IN ( 1, 2, 10, 11, 15, 21 ) -- Solicitado, Recolectado, En Inventario, Arribó a las instalaciones, Generado, Recibido en EXC
				  AND SDFG.IsDelivery = 1
		)
		BEGIN
			SELECT 201 AS IdResult,
				   DO.Receiver_Address AS receiverAddress,
				   'Delivery' AS serviceType,
				   IIF(SDFG.DateUsed IS NULL, 0, 1) AS updatedData,
				   'https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) + '/' AS trackingForza,
				   DO.Receiver_Department AS Province,
				   DO.Receiver_Town AS Township,
				   ISNULL(DO.TypeService, 'TDA') AS deliveryType
			FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
				INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
					ON DO.Guide_Serie = SDFG.GuideSerie
					   AND DO.Guide_Number = SDFG.GuideNumber
			WHERE SDFG.GuideToken = @GuideToken
				  AND DO.StatusOrderId IN ( 1, 2, 10, 11, 15, 21 ) -- Solicitado, Recolectado, En Inventario, Arribó a las instalaciones, Generado, Recibido en EXC
				  AND SDFG.IsDelivery = 1
		END
		-- Guía en estado no modificable
		ELSE
		BEGIN
			SELECT 206 AS IdResult,
				   'Delivery' AS serviceType,
				   'https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) AS trackingForza
			FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
				INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
					ON DO.Guide_Serie = SDFG.GuideSerie
					   AND DO.Guide_Number = SDFG.GuideNumber
			WHERE SDFG.GuideToken = @GuideToken
				  AND SDFG.IsDelivery = 1

		END
		-- Ultimo caso de error
		IF NOT EXISTS
		(
			SELECT TOP 1
				1
			FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
				INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
					ON DO.Guide_Serie = SDFG.GuideSerie
					   AND DO.Guide_Number = SDFG.GuideNumber
			WHERE SDFG.GuideToken = @GuideToken
				  AND SDFG.IsDelivery = 1
		)
		BEGIN

			SELECT 204 AS IdResult,
				   'No se encontraron registros validos.' AS [Message]

		END
		END TRY
		BEGIN CATCH

			SELECT 500 AS IdResult,
					ERROR_MESSAGE() AS Error

		END CATCH
	END
	-- Si es token de incidencias
	ELSE IF EXISTS (SELECT TOP 1 1 FROM ConfirmationOfIncidence coi WITH (NOLOCK) WHERE coi.ConfirmationOfIncidentToken = @GuideToken AND coi.RowStatus = 1)
	BEGIN
		BEGIN TRY

			IF ( EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI  WITH(NOLOCK) WHERE [COI].[ConfirmationOfIncidentToken] = @GuideToken AND [COI].[RowStatus] = 1 AND [COI].[IsConfirmed] = 0 AND [COI].[ConfirmationOfIncidentToken] NOT LIKE '%TIMEOUT' ) )
			BEGIN
				-- Buscar ubicación del VP
				SELECT		@VPLatitude = ISNULL([VPC].[Latitude], ''),
							@VPLongitude = ISNULL([VPC].[Longitude], '')
				FROM		[dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK)
				INNER JOIN	[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
					ON		[COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
				INNER JOIN	[dbo].[DeliveryOrder] DO WITH (NOLOCK)
					ON		[DA].[Guide_Serie] = [DO].[Guide_Serie] AND [DA].[Guide_Number] = [DO].[Guide_Number]
				INNER JOIN	[dbo].[VisitPointClient] VPC WITH (NOLOCK)
					ON		[VPC].[CodeOfReference] = (CASE WHEN [DO].[IsLastMileReturn] = 1 THEN [DO].[Sender_ID] ELSE [DO].[Receiver_ID] END)
				WHERE		[COI].[ConfirmationOfIncidentToken] = @GuideToken
					AND		[COI].[RowStatus] = 1
					AND		[COI].[IsConfirmed] <> 1;


				SELECT 202 AS IdResult,
				   CASE
						WHEN do.IsLastMileReturn = 1 THEN
							do.Sender_Address
						ELSE
							do.Receiver_Address
					END AS receiverAddress,
				   CASE
						WHEN do.IsLastMileReturn = 1 THEN
							do.[Sender_Phone]
						ELSE
							do.[Receiver_Phone]
					END AS receiverPhone,
				   'Incidence' AS serviceType,
				   'https://forzadelivery.com/rastreo/' + do.Guide_Serie + CAST(do.Guide_Number AS NVARCHAR) + '/' AS trackingForza,
				    CASE
						  WHEN do.IsLastMileReturn = 1 THEN
							  do.Sender_Department
						  ELSE
							  do.Receiver_Department
					END AS Province,
				    CASE
						WHEN do.IsLastMileReturn = 1 THEN
							do.Sender_Town
						ELSE
							do.Receiver_Town
					END AS Township,
				   CAST(DO.Guide_Serie AS NVARCHAR) AS GuideSerie,
				   CAST(DO.Guide_Number AS NVARCHAR) AS GuideNumber,
				   ISNULL(DO.[IsLastMileReturn], 0) AS IsLastMileReturn,
				   coi.IdConfirmationOfIncidence AS confirmationOfIncidenceId,
				   CASE
					   WHEN DA.Longitude IS NOT NULL
							AND DA.Latitude IS NOT NULL
							AND @VPLongitude <> ''
							AND @VPLatitude <> ''
							AND GEOGRAPHY::STPointFromText(CONCAT('POINT (', @VPLongitude, ' ', @VPLatitude, ')'), 4326)
								.STDistance(GEOGRAPHY::STPointFromText(CONCAT('POINT (', DA.Longitude, ' ', DA.Latitude, ')'), 4326)) <= @MaxDistance
					   THEN
						   1
					   ELSE
						   0
				   END AS FlagLogitudes,
				   ISNULL(da.Latitude, '') AS courierLatitude,
				   ISNULL(da.Longitude, '') AS courierLongitude,
				   ISNULL(cti.DescriptionIncidence, '') AS incidenceDescription
			FROM ConfirmationOfIncidence coi WITH (NOLOCK)
				INNER JOIN DeliveryAttempt da WITH (NOLOCK)
					ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = da.Guide_Serie
					   AND do.Guide_Number = da.Guide_Number
				LEFT JOIN CatTypeIncidence cti WITH (NOLOCK)
					ON da.ID_Incident = cti.IdIncidenceType
			WHERE coi.ConfirmationOfIncidentToken = @GuideToken
				  AND coi.RowStatus = 1;

			WITH DynamicFields
			AS (SELECT IDI.CatTypeIncidenceId,
					   IDI.FieldName,
					   IDI.FieldType,
					   IDI.IsEditable
				FROM dbo.IncidenceDynamicInput IDI WITH (NOLOCK)
				WHERE IDI.RowStatus = 1
			   ),
				 QuestionData
			AS (SELECT IDQ.CatTypeIncidenceId,
					   IDQ.QuestionTrue,
					   IDQ.QuestionFalse,
					   IDQ.SpecialInstructions
				FROM dbo.IncidenceDynamicQuestion IDQ WITH (NOLOCK)
				WHERE IDQ.RowStatus = 1
			   )

			SELECT DF.FieldName,
				   DF.FieldType,
				   DF.IsEditable,
				   QD.QuestionTrue,
				   QD.QuestionFalse,
				   QD.SpecialInstructions
			FROM ConfirmationOfIncidence COI WITH (NOLOCK)
				INNER JOIN DeliveryAttempt DA WITH (NOLOCK)
					ON COI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
				INNER JOIN DeliveryOrder DO WITH (NOLOCK)
					ON DO.Guide_Serie = DA.Guide_Serie
					   AND DO.Guide_Number = DA.Guide_Number
				LEFT JOIN CatTypeIncidence CTI WITH (NOLOCK)
					ON DA.ID_Incident = CTI.IdIncidenceType
				LEFT JOIN DynamicFields DF WITH (NOLOCK)
					ON CTI.IdIncidenceType = DF.CatTypeIncidenceId
				LEFT JOIN QuestionData QD WITH (NOLOCK)
					ON CTI.IdIncidenceType = QD.CatTypeIncidenceId
			WHERE COI.ConfirmationOfIncidentToken = @GuideToken
				  AND COI.RowStatus = 1;

			END
			ELSE 
			BEGIN
			         
				SELECT 206 AS IdResult,
					   'DeliveryInRoute' AS serviceType,
					   'https://forzadelivery.com/rastreo/' + do.Guide_Serie + CAST(do.Guide_Number AS NVARCHAR) + '/' AS trackingForza
				FROM ConfirmationOfIncidence coi WITH (NOLOCK)
					INNER JOIN DeliveryAttempt da WITH (NOLOCK)
						ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
					INNER JOIN DeliveryOrder do WITH (NOLOCK)
						ON do.Guide_Serie = da.Guide_Serie
						   AND do.Guide_Number = da.Guide_Number
					LEFT JOIN CatTypeIncidence cti WITH (NOLOCK)
						ON da.ID_Incident = cti.IdIncidenceType
				WHERE coi.ConfirmationOfIncidentToken = @GuideToken
					  AND coi.RowStatus = 1

		    END

			IF NOT EXISTS
			(
				SELECT TOP 1
					1
				FROM ConfirmationOfIncidence coi WITH (NOLOCK)
					INNER JOIN DeliveryAttempt da WITH (NOLOCK)
						ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
					INNER JOIN DeliveryOrder do WITH (NOLOCK)
						ON do.Guide_Serie = da.Guide_Serie
						   AND do.Guide_Number = da.Guide_Number
					LEFT JOIN CatTypeIncidence cti WITH (NOLOCK)
						ON da.ID_Incident = cti.IdIncidenceType
				WHERE coi.ConfirmationOfIncidentToken = @GuideToken
					  AND coi.RowStatus = 1
			)
			BEGIN
				SELECT 204 AS IdResult,
					   'No se encontraron registros validos.' AS [Message]
			END
		END TRY
		BEGIN CATCH

				SELECT 500 AS IdResult,
					ERROR_MESSAGE() AS Error
		END CATCH
	END	
	ELSE -- Otro tipo de token
	BEGIN
		/* OTROS FLUJOS - POR IMPLEMENTAR */

		SELECT 204 AS IdResult,
				'No se encontraron registros validos.' AS [Message]
	END
END
