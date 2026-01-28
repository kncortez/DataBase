/* =================================================
   SP:        SPHW_GetNewDeliveryTracking
   Propósito: Delivery Tracking – Obtener información de seguimiento de guía personalizado al nuevo tracking.
              Contenerización – Agrega TicketNumber como código de referencia y busca relación con guía asociada.
   Autor:     Walter Orozco
   Historia:  ---
   Fecha:     2024-10-11

=== CHANGELOG ============================

2025-02-14 | Historia/épica: ---         | Autor: Brandon Pedroza | Contenerización – Ajuste para obtener número de guía cuando no se envía referencia
2026-01-17 | Historia/épica: FDAPI-5378  | Autor: Brandon Pedroza | Se obtienen checkpoint validos  de guías(rowstatus = 1)

=========================================== */

CREATE PROCEDURE [dbo].[SPHW_GetNewDeliveryTracking]
@TicketNumber NVARCHAR(300),
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@IdCustomer INT = NULL,
@Phone NVARCHAR(200)
AS
BEGIN
BEGIN TRY
	
	DECLARE @GuideCount INT = 0;--Contador para duplicidad de guías por ticket number

	IF(@TicketNumber != '' AND @GuideSerie = '' AND @GuideNumber < 1)
	BEGIN
		SELECT
			@GuideSerie = ISNULL(Guide_Serie,''),
			@GuideNumber = ISNULL(Guide_Number,0),
			@GuideCount = COUNT(Guide_Number) OVER ()
		FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
		WHERE Ticket_Number = @TicketNumber 
		AND (@IdCustomer IS NULL OR IdCustomer = @IdCustomer);
	END
	ELSE
	BEGIN
		SELECT
			@GuideSerie = ISNULL(Guide_Serie,''),
			@GuideNumber = ISNULL(Guide_Number,0),
			@GuideCount = COUNT(Guide_Number) OVER ()
		FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
		WHERE Guide_Serie = @GuideSerie
		AND Guide_Number = @GuideNumber;			
	END;

	IF(@GuideSerie != '' AND @GuideNumber > 0 AND @GuideCount = 1)
	BEGIN
		DECLARE @Receiver_Phone NVARCHAR(200) = (SELECT RIGHT(LTRIM(RTRIM(Receiver_Phone)), 8) FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber);

		DECLARE @CodeArea NVARCHAR(5) = (
			SELECT 
				CASE 
					-- Caso 1: El número comienza con '+' y tiene al menos 11 dígitos (ej. +50244444444)
					WHEN LEFT(DO.Receiver_Phone, 1) = '+' AND LEN(DO.Receiver_Phone) >= 11 THEN 
						SUBSTRING(DO.Receiver_Phone, 2, 3)

					-- Caso 2: El número comienza con un código de área sin '+' y tiene al menos 10 dígitos (ej. 50244444444)
					WHEN LEN(DO.Receiver_Phone) >= 10 AND ISNUMERIC(LEFT(DO.Receiver_Phone, 3)) = 1 THEN 
						LEFT(DO.Receiver_Phone, 3)

					-- Caso 3: Si no tiene código de área válido, devuelve NULL (ej. 2345-6789)
					ELSE ISNULL(C.[Value],'502')
				END AS 'AreaCode'
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams C WITH(NOLOCK)
				ON C.[Name] = 'AreaCode' AND ISNULL(DO.ReceiverCountryId,'GT') = C.IdCountry
			WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
		);

		--Validación del telefono
		IF((@Phone = @Receiver_Phone) OR (@Phone = @CodeArea + @Receiver_Phone) OR (@Phone = '+' + @CodeArea + @Receiver_Phone))
		BEGIN
			SELECT 
				  200						 AS 'IdResult'
				, 'Exitoso.'				 AS 'Message'
		END;
		ELSE
		BEGIN
			SELECT 
				  201 AS 'IdResult'
				, 'El número ingresado no coincide con el registrado para este envío.' AS 'Message'
		END;

		--------------------------------------------------------------------------------------------
		------------------------------------TRACKING------------------------------------------------
		--------------------------------------------------------------------------------------------

		--SOLO SE MUESTRAN ESTADOS PUBLICOS
		DECLARE @ExternalTypeId INT =
				(
					SELECT CST.IdCatStatusType
					FROM [DeliveryBackOffice].[dbo].[CatStatusType] CST WITH (NOLOCK)
					WHERE CST.StatusType = 'Externo'
				);

		DECLARE @GuideOrderTemp AS TABLE
		(
			Guide_Serie NVARCHAR(2)
		  , Guide_Number INT
		  , SenderName NVARCHAR(200)
		  , Sender_Address NVARCHAR(600)
		  , ReceiverName NVARCHAR(200)
		  , Receiver_Address NVARCHAR(600)
		  , Manifest_Serie NVARCHAR(2)
		  , Manifest_Number INT
		  , NameOfReceiver NVARCHAR(200)
		  , Delivery_Max_Date DATETIME
		  , Receiver_Phone NVARCHAR(100)
		  , Price_Guide DECIMAL(14, 2)
		  , Price_COD DECIMAL(14, 2)
		);

		-- Variables de datos de entrega
		DECLARE @GuideDeliveryLatitude NVARCHAR(20) = N'';
		DECLARE @GuideDeliveryLongitude NVARCHAR(20) = N'';
		DECLARE @StatusIncident INT;
		DECLARE @StatusIncidentValidated INT;

		SET @StatusIncident =
		(
			SELECT StatusOrderId
			FROM StatusOrder WITH (NOLOCK)
			WHERE OrderDescription = 'Incidencia en ruta'
		);
		SET @StatusIncidentValidated =
		(
			SELECT StatusOrderId
			FROM StatusOrder WITH (NOLOCK)
			WHERE OrderDescription = 'Incidencia Validada'
		);

		--QUEDA PENDIENTE YA QUE ESTE VALOR DE LONGITUD Y LATITUD SE PUEDE SACAR DESDE LA DELIVERY ORDER EN LA CONSULTA DE ABAJO
		 SELECT TOP 1
			   @GuideDeliveryLatitude  = DA.Latitude
			 , @GuideDeliveryLongitude = DA.Longitude
		FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt]          DA WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryProof]  DP WITH (NOLOCK)
				ON DA.Guide_Serie = DP.Guide_Serie
				   AND DA.Guide_Number = DP.Guide_Number
		WHERE DA.Guide_Serie = @GuideSerie
			  AND DA.Guide_Number = @GuideNumber
			  AND DA.Delivered = 1
		ORDER BY DA.Date_Created DESC;

		-- Datos de guía
		INSERT INTO @GuideOrderTemp
		(
			Guide_Serie
		  , Guide_Number
		  , SenderName
		  , Sender_Address
		  , ReceiverName
		  , Receiver_Address
		  , Manifest_Serie
		  , Manifest_Number
		  , NameOfReceiver
		  , Delivery_Max_Date
		  , Receiver_Phone
		  , Price_Guide
		  , Price_COD
		)
		SELECT
			   DO.Guide_Serie
			 , DO.Guide_Number
			 , LTRIM(RTRIM(ISNULL(DO.Sender_FirstName, '') + ' ' + ISNULL(DO.Sender_LastName, '')))
			 , Sender_Address
			 , LTRIM(RTRIM(ISNULL(DO.Receiver_FirstName, '') + ' ' + ISNULL(DO.Receiver_LastName, '')))
			 , DO.Receiver_Address
			 , DO.Manifest_Serie
			 , DO.Manifest_Number
			 , DO.NameOfReceiver
			 , DO.Delivery_Max_Date
			 , RIGHT(LTRIM(RTRIM(DO.Receiver_Phone)), 8)
			 , DO.PriceShippment
			 , DO.Collect_OnDelivery
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
		WHERE DO.Guide_Serie = @GuideSerie
			  AND DO.Guide_Number = @GuideNumber;

		--CONSULTA FINAL

		SELECT RES.[EventID]
			 , RES.[OrderId]
			 , RES.[GuideSerie]
			 , RES.[GuideNumber]
			 , RES.[CustomerFullname]
			 , RES.[EstimatedDeliveryDate]
			 , RES.[CourierName]
			 , RES.[StageId]
			 , RES.[StageDate]
			 , RES.[StageTitle]
			 , RES.[StageSource]
			 , RES.[ClasificationIncident]
			 , RES.[StageDescription]
			 , RES.[CheckpointIcon]
			 , RES.[NameOfReceiver]
			 , RES.[Place]
			 , RES.[NextSteps]
			 , RES.[ImagePath]
			 , RES.[Dry]
			 , RES.[Cold]
			 , RES.[Latitude]
			 , RES.[Longitude]
			 , RES.Receiver_Phone
			 , RES.Price_Guide
			 , RES.Price_COD
			 , RES.UserIncident
			 , RES.StatusValidated
			 , RES.ValidGeolocationEvidence
			 , RES.ValidPhotographicEvidence
		FROM
		(
			SELECT 
				   0                                                 AS [EventID]
				 , do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) AS [OrderId]
				 , do.Guide_Serie									 AS [GuideSerie]
				 , CAST(do.Guide_Number AS VARCHAR)					 AS [GuideNumber]
				 , do.ReceiverName                                   AS [CustomerFullname]
				 , CONVERT(VARCHAR, do.Delivery_Max_Date, 120)       AS [EstimatedDeliveryDate]
				 , ''                                                AS [CourierName]
				 , ''                                                AS [StageId]
				 , ''                                                AS [StageDate]
				 , ''                                                AS [StageTitle]
				 , 'web'                                             AS [StageSource]
				 , ''                                                AS [ClasificationIncident]
				 , ''                                                AS [StageDescription]
				 , ''                                                AS [CheckpointIcon]
				 , ISNULL([NameOfReceiver], '')                      AS [NameOfReceiver]
				 , ISNULL(do.SenderName, '')                         AS [Place]
				 , ''                                                AS [NextSteps]
				 , ''                                                AS [ImagePath]
				 , ''                                                AS [Dry]
				 , ''                                                AS [Cold]
				 , ''                                                AS [Latitude]
				 , ''                                                AS [Longitude]
				 , do.Receiver_Phone								 AS [Receiver_Phone]
				 , ISNULL(do.Price_Guide, 0)                         AS [Price_Guide]
				 , ISNULL(do.Price_COD, 0)                           AS [Price_COD]
				 , ''                                                AS [UserIncident]
				 , 0                                                 AS [StatusValidated]
				 , 0                                                 AS [ValidGeolocationEvidence]
				 , 0                                                 AS [ValidPhotographicEvidence]
			FROM @GuideOrderTemp do
			UNION
			SELECT DISTINCT
				   RANK() OVER (PARTITION BY dod.Guide_Number ORDER BY dod.DateCreated ASC)     AS [EventID]
				 , dod.Guide_Serie + CAST(dod.Guide_Number AS VARCHAR)                          AS [OrderId]            
				 , dod.Guide_Serie										                        AS [GuideSerie]            
				 , CAST(dod.Guide_Number AS VARCHAR)											AS [GuideNumber]            
				 , ''                                                                           AS [CustomerFullname]      
				 , ''                                                                           AS [EstimatedDeliveryDate] 
				 , ''                                                                           AS [CourierName]           
				 , CAST(dod.StatusOrderId AS NVARCHAR)                                          AS [StageId]            
				 , dod.DateCreated																AS [StageDate]
				 , (CASE
						WHEN dod.StatusOrderId = @StatusIncident THEN
							so.OrderDescription
						WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
							so.OrderDescription
						ELSE
							so.OrderDescription
                         
					END)                                                                        AS [StageTitle]       
				 , 'web'                                                                        AS [StageSource]
				 , (CASE
						WHEN dod.StatusOrderId = @StatusIncident THEN
						(
							SELECT TOP 1
								   cic.IncidenceTypeName
							FROM DeliveryAttempt                     dla WITH (NOLOCK)
								INNER JOIN CatTypeIncidence          cti WITH (NOLOCK)
									ON dla.ID_Incident = cti.IdIncidenceType
								INNER JOIN CatIncidenceClasification cic WITH (NOLOCK)
									ON cti.IncidenceClasificationId = cic.IdCatIncidenceClasification
							WHERE dod.Guide_Serie = @GuideSerie
								  AND dod.Guide_Number = @GuideNumber
								  AND dod.DeliveryAttemptId = dla.ID
						)
						ELSE
							''
					END)                                                                        AS [ClasificationIncident]
				 , (CASE
					WHEN dod.StatusOrderId = @StatusIncident THEN
						(CASE
						  WHEN
						  (
							  SELECT TOP 1
									 cic.IncidenceTypeName
							  FROM DeliveryAttempt                     dla WITH (NOLOCK)
								  INNER JOIN CatTypeIncidence          cti WITH (NOLOCK)
									  ON dla.ID_Incident = cti.IdIncidenceType
								  INNER JOIN CatIncidenceClasification cic WITH (NOLOCK)
									  ON cti.IncidenceClasificationId = cic.IdCatIncidenceClasification
							  WHERE dod.Guide_Serie = @GuideSerie
									AND dod.Guide_Number = @GuideNumber
									AND dod.DeliveryAttemptId = dla.ID
							) = 'Incidencias operativas' THEN
							(
								SELECT TOP 1
									   cti.NameIncidencePublic
								FROM DeliveryAttempt            dla WITH (NOLOCK)
									INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
										ON dla.ID_Incident = cti.IdIncidenceType
								WHERE dod.Guide_Serie = @GuideSerie
									  AND dod.Guide_Number = @GuideNumber
									  AND dod.DeliveryAttemptId = dla.ID
							)
							ELSE
							(
								SELECT TOP 1
									   cti.NameIncidence
								FROM DeliveryAttempt            dla WITH (NOLOCK)
									INNER JOIN CatTypeIncidence cti WITH (NOLOCK)
										ON dla.ID_Incident = cti.IdIncidenceType
								WHERE dod.Guide_Serie = @GuideSerie
									  AND dod.Guide_Number = @GuideNumber
									  AND dod.DeliveryAttemptId = dla.ID
							)
							END)
					  WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
						  dod.Observations
					  ELSE
						  so.OrderDescription + IIF(dod.Observations IS NULL OR dod.Observations = '', '', ', ' + CAST(dod.Observations AS NVARCHAR(50)))
					END)                                                                        AS [StageDescription]         
				 , IIF(so.CatCheckpointTypeId = 4 , 'bi bi-exclamation-lg' , 'bi bi-check2')    AS [CheckpointIcon]
				 , (CASE
						WHEN dod.StatusOrderId = 5 THEN
						(
							SELECT TOP 1 NameOfReceiver FROM @GuideOrderTemp
						)
						ELSE
							''
					END)                                                                        AS [NameOfReceiver]
				 , ''                                                                           AS [Place]
				 , ISNULL(so.NextSteps,'')                                                      AS [NextSteps]
				 , (CASE
						WHEN dod.StatusOrderId = 5 THEN
							IIF((
									SELECT TOP 1
										   Path_Dry
									FROM DeliveryProof WITH (NOLOCK)
									WHERE Guide_Serie = @GuideSerie
										  AND Guide_Number = @GuideNumber
								) IS NOT NULL
							  , (
									SELECT TOP 1
										   Path_Dry
									FROM DeliveryProof WITH (NOLOCK)
									WHERE Guide_Serie = @GuideSerie
										  AND Guide_Number = @GuideNumber
								)
							  , (
									SELECT TOP 1
										   Path_Cold
									FROM DeliveryProof WITH (NOLOCK)
									WHERE Guide_Serie = @GuideSerie
										  AND Guide_Number = @GuideNumber
								))
						WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
						(
							SELECT TOP 1
								   dlp.Path_Incident
							FROM dbo.DeliveryAttempt               datt WITH (NOLOCK)
								INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
									ON datt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
								INNER JOIN dbo.DeliveryProof       dlp WITH (NOLOCK)
									ON datt.ID_Proof = dlp.ID
							WHERE dod.Guide_Serie = @GuideSerie
								  AND dod.Guide_Number = @GuideNumber
								  AND dod.DeliveryAttemptId = datt.ID
								  AND
								  (
									  cfo.IsDenied = 0
									  OR cfo.IsDenied IS NULL
								  )
						)
						ELSE
							''
					END)                                                                            AS [ImagePath]
				 , (CASE
						WHEN dod.StatusOrderId = 5 THEN
						(
							SELECT TOP 1
								   IIF([dp].[Path_Dry] = '', dp.Path_Dry, ISNULL([Path_Dry], [Path_Dry]))
							FROM [DeliveryBackOffice].[dbo].[DeliveryProof]       dp WITH (NOLOCK)
								INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
									ON da.Guide_Serie = dp.Guide_Serie
									   AND da.Guide_Number = dp.Guide_Number
							WHERE dp.Guide_Serie = @GuideSerie
								  AND dp.Guide_Number = @GuideNumber
								  AND da.Delivered = 1
							ORDER BY dp.Date_Photo DESC
						)
						ELSE
							''
					END)                                                                            AS [Dry]
				 , (CASE
						WHEN dod.StatusOrderId = 5 THEN
						(
							SELECT TOP 1
								   IIF([dp].[Path_Cold] = '', dp.Path_Cold, ISNULL([Path_Cold], [Path_Cold]))
							FROM [DeliveryBackOffice].[dbo].[DeliveryProof]       dp WITH (NOLOCK)
								INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
									ON da.Guide_Serie = dp.Guide_Serie
									   AND da.Guide_Number = dp.Guide_Number
							WHERE dp.Guide_Serie = @GuideSerie
								  AND dp.Guide_Number = @GuideNumber
								  AND da.Delivered = 1
							ORDER BY dp.Date_Photo DESC
						)
						ELSE
							''
					END)                                                                            AS [Cold]
				 , (CASE
						WHEN dod.StatusOrderId = 5 THEN
							@GuideDeliveryLatitude
						WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
						(
							SELECT TOP 1
								   Latitude
							FROM DeliveryAttempt                   dt WITH (NOLOCK)
								INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
									ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
							WHERE dod.Guide_Serie = @GuideSerie
								  AND dod.Guide_Number = @GuideNumber
								  AND dod.DeliveryAttemptId = dt.ID
								  AND dt.Delivered = 0
								  AND
								  (
									  cfo.IsDenied = 0
									  OR cfo.IsDenied IS NULL
								  )
						)
						ELSE
							''
					END)                                                                            AS [Latitude]
				 , (CASE
						WHEN dod.StatusOrderId = 5 THEN
							@GuideDeliveryLongitude
						WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
						(
							SELECT TOP 1
								   Longitude
							FROM DeliveryAttempt                   dt WITH (NOLOCK)
								INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
									ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
							WHERE dod.Guide_Serie = @GuideSerie
								  AND dod.Guide_Number = @GuideNumber
								  AND dt.Delivered = 0
								  AND dod.DeliveryAttemptId = dt.ID
								  AND
								  (
									  cfo.IsDenied = 0
									  OR cfo.IsDenied IS NULL
								  )
						)
						ELSE
							''
					END)                                                                            AS [Longitude]
				 , ''                                                                               AS [ReceiverPhone]
				 , 0                                                                                AS [PriceGuide]
				 , 0                                                                                AS [PriceCOD]
				 , ''                                                                               AS [UserIncident]
				 , (CASE
						WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
				 (@StatusIncidentValidated)
						ELSE
							0
					END)                                                                            AS [StatusValidated]
				 , IIF(
					   COI.ValidGeolocationEvidence IS NULL
					   AND dod.StatusOrderId = 50
					 , IIF(IsConfirmed = 1 AND IsDenied = 0 AND dod.StatusOrderId = 50, 1, 0)
					 , IIF(COI.ValidGeolocationEvidence = 1 AND dod.StatusOrderId = 50, 1, 0))      AS [ValidGeolocationEvidence]
				 , IIF(
					   COI.ValidPhotographicEvidence IS NULL
					   AND dod.StatusOrderId = 50
					 , IIF(IsConfirmed = 1 AND IsDenied = 0 AND dod.StatusOrderId = 50, 1, 0)
					 , IIF(COI.ValidPhotographicEvidence = 1 AND dod.StatusOrderId = 50, 1, 0))		AS [ValidPhotographicEvidence]
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]		dod WITH (NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]		so  WITH (NOLOCK)
					ON [so].[StatusOrderId] = [dod].[StatusOrderId]
				INNER JOIN [dbo].[CatCheckpointType]					CCT WITH (NOLOCK)
					ON [so].[CatCheckpointTypeId] = [CCT].[IdCatCheckpointType]
				LEFT JOIN [dbo].[DeliveryAttempt]						da  WITH (NOLOCK)
					ON [dod].[DeliveryAttemptId] = [da].[ID]
				LEFT JOIN [dbo].[ConfirmationOfIncidence]				COI WITH (NOLOCK)
					ON [da].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
			WHERE dod.Guide_Serie = @GuideSerie
				  AND dod.Guide_Number = @GuideNumber
				  AND so.CatStatusTypeId = @ExternalTypeId
				  AND DOD.RowStatus = 1
				  
		) RES
		ORDER BY RES.[StageDate] DESC
			   , RES.[EventID];
	END;
	ELSE
	BEGIN
		IF(@GuideCount > 1)
		BEGIN
			SELECT 
				  400 AS 'IdResult'
				, 'El número de referencia ingresado tiene varios clientes asignados' AS 'Message'
				, DO.Guide_Serie	AS 'GuideSerie'
				, DO.Guide_Number	AS 'GuideNumber'
				, C.IdCustomer AS 'IdCustomer'
				, C.Name AS 'CustomerName'
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.Customer C WITH(NOLOCK)
				ON DO.IdCustomer = C.IdCustomer
			WHERE DO.Ticket_Number = @TicketNumber 
			AND (@IdCustomer IS NULL OR DO.IdCustomer = @IdCustomer);
		END;
		ELSE
		BEGIN
			SELECT 
			  404 AS 'IdResult'
			, 'El número de referencia ingresado o escaneado no tiene una guía asociada. Verifica que el número de referencia sea correcto. Si el problema persiste, contacta a soporte.' AS 'Message'
		END;
	END;

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;