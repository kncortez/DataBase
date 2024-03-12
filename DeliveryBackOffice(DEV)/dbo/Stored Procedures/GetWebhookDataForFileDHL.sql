
-- =============================================
-- Author:		<Cristian,Azurdia>
-- Create date: <2024-02-26>
-- Description:	< Manejo de lotes para archivo SFTP de webhooks >
-- =============================================

CREATE PROCEDURE  [dbo].[GetWebhookDataForFileDHL] 
@T_TYPE INT,
@CUSTOMER_ID INT,
@LOTE INT,
@MESSAGE VARCHAR(100)
AS
BEGIN

	DECLARE @HOSTNAME VARCHAR(50);	
	DECLARE @FILENAME VARCHAR(50);
	DECLARE @LOTE_AUX BIGINT;

	/***************************************************************************
	************* EVALUAR QUE TIPO DE ACCIÓN SE VA A REALIZAR ******************
	****************************************************************************/
	IF(@T_TYPE = 1)
	BEGIN
		--PRINT '-- CREACION DE LOTE  --'
		SELECT @HOSTNAME = wep.Hostname FROM WebhookEndpoint wep WHERE wep.CustomerId = @CUSTOMER_ID;

		IF (@HOSTNAME <> '') 
		BEGIN
			--Definir el nombre del archivo y creación del lote
			SET @FILENAME = CONCAT('GT_FORZA_',FORMAT(GETDATE(),'yyyyMMdd_hhmmss'),'.txt');
			
			INSERT INTO [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP] ([FileName], [Hostname], [HasNotified], [RowStatus], [TokenCreated], [DateCreated])
			VALUES(@FILENAME, @HOSTNAME,0,1,'SYS-HERMESWEBHOOKS',GETDATE());

			SET @LOTE_AUX = IDENT_CURRENT('WebhookTrackingQueueForSFTP');

			SELECT @LOTE_AUX [Lote], @FILENAME [Filename];

			SELECT '202' [status], 'Acción Creacion de lote' [message];

		END
		ELSE
		BEGIN
			Select '404' [status], 'Customer No definido' [message];
		END

	END
	ELSE IF(@T_TYPE = 2)
	BEGIN

		--PRINT '-- ASIGNACIÓN DE GUIAS A LOTE GENERADO --'
		-- Guias no asignadas 
		UPDATE [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP] SET [WebhookTrackingQueueForSFTPId] = @LOTE WHERE [WebhookTrackingQueueForSFTPId] IS NULL 
		-- Guias con problemas y pendientes de asignar
		UPDATE [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP]
		SET [WebhookTrackingQueueDetailForSFTP].[WebhookTrackingQueueForSFTPId] = @LOTE 
		FROM [WebhookTrackingQueueDetailForSFTP] 
			LEFT JOIN  [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailPendingForSFTP]
			   ON [WebhookTrackingQueueDetailForSFTP].[IdWebhookTrackingQueueDetailForSFTP] = [WebhookTrackingQueueDetailPendingForSFTP].[IdWebhookTrackingQueueDetailPendingForSFTP]
			   AND [WebhookTrackingQueueDetailForSFTP].[WebhookTrackingQueueForSFTPId] = [WebhookTrackingQueueDetailPendingForSFTP].[WebhookTrackingQueueForSFTPId]
			LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP]
			   ON [WebhookTrackingQueueDetailForSFTP].[WebhookTrackingQueueForSFTPId] = [WebhookTrackingQueueForSFTP].[IdWebhookTrackingQueueForSFTP]
		WHERE [WebhookTrackingQueueForSFTP].[HasNotified] = 0;

		SELECT '202' [status], 'Acción Creacion de lote' [message];

	END
	ELSE IF(@T_TYPE = 3)
	BEGIN

		--PRINT '-- GENERACIÓN DE ARCHIVO QUE SE ENVIARA A FORZA --'
		-- Verificar si el lote existe
		IF EXISTS( Select [IdWebhookTrackingQueueForSFTP] from [dbo].[WebhookTrackingQueueForSFTP] WHERE [IdWebhookTrackingQueueForSFTP] = @LOTE )
		BEGIN 

			--Encabezado del archivo
			SELECT 'H' [Type], GETDATE() [Date_Time], 'FORZA' [Partner];

			WITH D as ( --Datos base del detalle
			SELECT  'D' [Type], 
					ROW_NUMBER() OVER(ORDER BY [WTQDFS].[IdWebhookTrackingQueueDetailForSFTP] ASC) AS [Counter], 
					'IST' [Service_Area_Code], 
					'CET' [Facility_Code], 
					--FORMAT(ISNULL(DOP.DateRegistrationExternalCode,'1900-01-01 00:00:00'),'yyyyMMdd') [CheckPointDate],
					--FORMAT(ISNULL(DOP.DateRegistrationExternalCode,'1900-01-01 00:00:00'),'HHmmss') [CheckPointTime],
					FORMAT(ISNULL(WTQDFS.[DateCreated],'1900-01-01 00:00:00'),'yyyyMMdd') [CheckPointDate],
					FORMAT(ISNULL(WTQDFS.[DateCreated],'1900-01-01 00:00:00'),'HHmmss') [CheckPointTime],
					'-06:00' [GTM_Offset],
					WTQDFS.[GuideSerie],
					WTQDFS.[GuideNumber],
					WTQDFS.[GuidePiece],
					WTQDFS.[ExternalNumber] [Waybill],
					WTQDFS.[ExternalPieceId][PieceId],
					WTQDFS.[TokenCreated],
					CASE WHEN [WTQDFS].[StatusOrderId] = 5 THEN 'OK' WHEN [WTQDFS].[StatusOrderId] = 22 THEN 'OK' ELSE 'FD' END [CheckPointCode],
					WTQDFS.[StatusOrderId] [DHL_Status],
					WTQDFS.[DeliveryAttemptId] [DHL_Incident],
					WTQDFS.[NewDeliveryDate],
					'GTW7' [Route_Code],
					'A' [Cycle_Code]
			FROM	
					[DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP] WTQDFS WITH(NOLOCK)
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)	
						   ON [DOP].[GuideNumber] = [WTQDFS].GuideNumber
						  AND [DOP].[GuideSerie] = [WTQDFS].GuideSerie
						  AND [DOP].[NoPiece] = [WTQDFS].[GuidePiece]
						  AND [WTQDFS].ExternalPieceId = [WTQDFS].[ExternalPieceId]
			WHERE	[WTQDFS].[WebhookTrackingQueueForSFTPId] = @LOTE
			
			),
			HEP AS( --Datos del lugar donde se registra el Checkpoint
				SELECT	[A1].[PieceId], 
						[A1].[Waybill], 
						[A1].[DHL_Status],
						ISNULL([A7].[DescriptionOfClient],'') [Station]
				FROM [D] A1 WITH (NOLOCK)
					LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken] A2 WITH (NOLOCK)
						ON A1.[TokenCreated] = A2.[SSN_IdToken]
					LEFT JOIN [DeliveryBackOffice].[dbo].[InternalUser] A3 WITH (NOLOCK)
						ON A2.[SSN_IdUser] = A3.[IdUser]
						   AND A2.[SSN_Username] = A3.[Username]
					OUTER APPLY
					(
						SELECT TOP 1 [A4].[StationId]
						FROM [dbo].[RolByUserBySystem] A4 WITH (NOLOCK)
						WHERE A4.[RusIdUser] = A3.[RegisterUserID]
							  AND [StationId] IS NOT NULL
						ORDER BY StationId
					) A5
					LEFT JOIN [dbo].[CatStation] A6 WITH (NOLOCK)
						ON A5.[StationId] = A6.[IdStation]
					LEFT JOIN [dbo].[VisitPointClient] A7 WITH (NOLOCK)
						ON A7.[CodeOfReference] = A6.[CodeOfReference]
				WHERE  A3.RowStatus = 1
			),
			DSO AS( --Obtener detalle del estatus
				SELECT  [D].[PieceId], 
						[D].[Waybill], 
						[D].[DHL_Status],
					    CASE WHEN [SOE].[IdStatusOrderExternal] = 1  --Recolecta
							 THEN CONCAT([SOE].[Remark],'FORZA ',D.GuideSerie,D.GuideNumber,'-',D.GuidePiece)
							 WHEN [SOE].IdStatusOrderExternal = 2  --Arrivo
							 THEN CONCAT([SOE].[Remark],'FORZA ',(SELECT HEP.[Station] FROM HEP WHERE HEP.Waybill = D.Waybill AND HEP.PieceId = D.PieceId AND HEP.[DHL_Status] = D.DHL_Status))
							 WHEN [SOE].IdStatusOrderExternal = 6  --Inventario
							 THEN CONCAT([SOE].[Remark],'FORZA ',(SELECT HEP.[Station] FROM HEP WHERE HEP.Waybill = D.Waybill AND HEP.PieceId = D.PieceId AND HEP.[DHL_Status] = D.DHL_Status))
							 WHEN [SOE].IdStatusOrderExternal = 8  --En Ruta
							 THEN CONCAT([SOE].[Remark],'')
							 WHEN [SOE].IdStatusOrderExternal = 9  --Entrega
							 THEN CONCAT([SOE].[Remark], ' ' ,[DO].NameOfReceiver)
							 ELSE [SOE].[Remark]                   --Todo lo demás
							 END [DHL_Checkpoint_Remark_DSO]
				FROM D
				LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrderRelation] SOR
					ON [SOR].[StatusOrderId] = [D].[DHL_Status]
				LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrderExternal] SOE
					ON [SOE].[IdStatusOrderExternal] = [SOR].[StatusOrderExternalId]
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO
					ON [DO].[Guide_Serie] = [D].[GuideSerie]
				   AND [DO].[Guide_Number] = [D].[GuideNumber]
				WHERE D.DHL_Status <> 50
				  AND [SOR].[RowStatus] = 1
				  AND [SOE].[RowStatus] = 1
				  --AND [SOE].[CustomerId] = @CUSTOMER_ID
			),
			DI AS( --Obeter detalle de la incidencia
				SELECT  [D].[PieceId], 
						[D].[Waybill],
						[D].[DHL_Status],
						CASE WHEN [SOE].[IdStatusOrderExternal] = 3
							 THEN CONCAT([SOE].[Remark],'')
							 WHEN [SOE].IdStatusOrderExternal = 4
							 THEN CONCAT([SOE].[Remark], FORMAT(ISNULL(D.[NewDeliveryDate],'1900-01-01 00:00:00'),'yyMM'), ' PM' )
							 WHEN [SOE].IdStatusOrderExternal = 5
							 THEN CONCAT([SOE].[Remark],'')
							 ELSE [SOE].[Remark]
							 END [DHL_Checkpoint_Remark_DI]
				FROM D
				RIGHT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA
					ON [DA].[ID] = [D].[DHL_Incident]
				LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI
					ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
				LEFT JOIN [DeliveryBackOffice].[dbo].[IncidentTypeRelation] ITR
					ON [ITR].[IncidenceTypeId] = [DA].[ID_Incident]
			   LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrderExternal] SOE
					ON [SOE].[IdStatusOrderExternal] = [ITR].[StatusOrderExternalId]
				WHERE D.[DHL_Status] = 50
				  AND [COI].[StatusOrderId] = 50
				  AND [COI].[IsConfirmed] = 1
				  AND [COI].[IsDenied] = 0
				  AND [COI].[RowStatus] = 1
				  AND [ITR].[RowStatus] = 1
				  --AND [SOE].[CustomerId] = @CUSTOMER_ID
			)
			
			--SELECT * FROM D;
			--Detalle del archivo Final
			SELECT	D.[Type], 
				    --'R' [Type],
					D.[Counter], 
					D.[Service_Area_Code],
					D.[Facility_Code],
					D.[CheckPointDate],
					D.[CheckPointTime],
					D.[GTM_Offset],
					D.[Waybill],
					D.[PieceId],
					D.[CheckPointCode],
				    CASE WHEN [D].[DHL_Status] = 50
					THEN (SELECT TOP 1 [DI].[DHL_Checkpoint_Remark_DI] FROM DI WHERE DI.[Waybill] = D.[Waybill] AND DI.[PieceId] = D.[PieceId] AND DI.[DHL_Status] = D.[DHL_Status])
					ELSE (SELECT TOP 1 [DSO].[DHL_Checkpoint_Remark_DSO] FROM DSO WHERE DSO.[Waybill] = D.[Waybill] AND DSO.[PieceId] = D.[PieceId] AND DSO.[DHL_Status] = D.[DHL_Status])
					END [DHL_Checkpoint_Remark],
					--'ERROR' [DHL_Checkpoint_Remark],
					D.[Route_Code],
					D.[Cycle_Code]
			FROM D
	    	ORDER BY [Counter] ASC
			
			--Pie de página del archivo
			SELECT	'T' [Type], 
					COUNT(IdWebhookTrackingQueueDetailForSFTP) [Total_Pieces] 
			FROM	[DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP]
			WHERE	[WebhookTrackingQueueForSFTPId] = @LOTE;

		END
		ELSE 
		BEGIN
			Select '404' [status], 'Lote No Existente' [message];
		END
	END
	ELSE IF (@T_TYPE = 4)
	BEGIN
		--PRINT '-- ACTUALIZACION DEL ESTATUS DEL LOTE ESPECIFICADO (CREACIÓN DEL ARCHIVO Y LOTE) --'
		UPDATE [DeliveryBackOffice].[dbo].WebhookTrackingQueueForSFTP 
		SET		[ShippingDate] = GETDATE(),
				[TokenUpdated] = 'SYS-HERMESWEBHOOKS',
				[DateUpdated] = GETDATE()
		WHERE [IdWebhookTrackingQueueForSFTP] = @LOTE;

	END
	ELSE IF (@T_TYPE = 5)
	BEGIN
		
		SELECT @HOSTNAME = wep.Hostname FROM WebhookEndpoint wep WHERE wep.CustomerId = @CUSTOMER_ID

		IF (@HOSTNAME <> '' AND ISNULL(@LOTE,0) <> 0) --Si el Customer cuenta con Hostname
		BEGIN
			SELECT [Hostname], [UserName], [Password], [Port] FROM WebhookEndpoint wep WHERE wep.CustomerId = @CUSTOMER_ID

			SELECT '202' [status], 'Acción Creacion de lote' [message];
		END
		ELSE
		BEGIN
			Select '404' [status], 'Customer No definido' [message];
		END
	END
	ELSE IF (@T_TYPE = 6)
	BEGIN
		
		--PRINT '-- ACTUALIZACION DEL ESTATUS DEL LOTE ESPECIFICADO (ARCHIVO ENVIADO O CON PROBLEMAS) --'
		IF(@MESSAGE = '')
		BEGIN
			--PRINT '-- ARCHIVO ACEPTADO --'
		-- Se actualiza encabezado y deja constancia de que concluyo la entrega del archivo
			UPDATE [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP] 
			SET		[HasNotified] = 1, 
					[SenderResponse] = 'OK', 
					[RegistrationDate] = GETDATE(),
					[TokenUpdated] = 'SYS-HERMESWEBHOOKS',
					[DateUpdated] = GETDATE()
			WHERE [IdWebhookTrackingQueueForSFTP] = @LOTE;

		-- Se actualiza encabezados pendientes y que se concluyeron en la entrega del archivo
			UPDATE [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailPendingForSFTP]
			SET		[TokenUpdated] = 'SYST-CAZURDIA',
					[DateUpdated] = GETDATE()
			FROM  [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailPendingForSFTP] WITH(NOLOCK)
			LEFT JOIN [dbo].[WebhookTrackingQueueDetailForSFTP] WTQDFS WITH(NOLOCK)
				  ON  [WebhookTrackingQueueDetailPendingForSFTP].[IdWebhookTrackingQueueDetailPendingForSFTP] = [WTQDFS].[IdWebhookTrackingQueueDetailForSFTP]
				   AND [WebhookTrackingQueueDetailPendingForSFTP].[WebhookTrackingQueueForSFTPId] = [WTQDFS].[WebhookTrackingQueueForSFTPId]
			INNER JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP] WTQFS WITH(NOLOCK)
			      ON  [WebhookTrackingQueueDetailPendingForSFTP].[WebhookTrackingQueueForSFTPId] = [WTQFS].[IdWebhookTrackingQueueForSFTP]
			WHERE 
				 WTQFS.HasNotified = 0
			
			UPDATE [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP] 
			SET		[HasNotified] = 1,
				    [TokenUpdated] = 'SYS-HERMESWEBHOOKS',
					[DateUpdated] = GETDATE()
			FROM   [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP]  WITH(NOLOCK)
			INNER JOIN [WebhookTrackingQueueDetailPendingForSFTP] WTQDPFS WITH(NOLOCK)
				   ON [WebhookTrackingQueueForSFTP].[IdWebhookTrackingQueueForSFTP] = [WTQDPFS].[WebhookTrackingQueueForSFTPId]
			LEFT JOIN [WebhookTrackingQueueDetailForSFTP] WTQDFS WITH(NOLOCK)
				   ON  [WTQDFS].[WebhookTrackingQueueForSFTPId] = [WebhookTrackingQueueForSFTP].[IdWebhookTrackingQueueForSFTP]
				  AND  [WTQDFS].[IdWebhookTrackingQueueDetailForSFTP] = [WTQDPFS].[IdWebhookTrackingQueueDetailPendingForSFTP]

			Select '202' [status], 'Lote Estatus Actualizado' [message];
		END
		ELSE
		BEGIN
			--PRINT '-- ARCHIVO PENDIENTE --'
			-- Se actualiza encabezado y deja constancia del porque no se concluyo la entrega del archivo
			UPDATE [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP] 
			SET		[HasNotified] = 0, 
					[SenderResponse] = @MESSAGE, 
					[RegistrationDate] = GETDATE() 
			WHERE [IdWebhookTrackingQueueForSFTP] = @LOTE;

			-- Se actualiza encabezado y deja constancia del porque no se concluyo la entrega del archivo
			INSERT INTO [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailPendingForSFTP]([WebhookTrackingQueueForSFTPId],[IdWebhookTrackingQueueDetailPendingForSFTP],[RowStatus],[TokenCreated],[DateCreated])
			SELECT [WebhookTrackingQueueForSFTPId], [IdWebhookTrackingQueueDetailForSFTP], 1, 'SYS-HERMESWEBHOOKS', GETDATE() 
			FROM [dbo].[WebhookTrackingQueueDetailForSFTP] 
			WHERE [WebhookTrackingQueueForSFTPId] = @LOTE;

			Select '202' [status], 'Lote Estatus Actualizado' [message];
		END

	END
	ELSE 
	BEGIN
		Select '404' [status], 'Acción No definida' [message];
	END
END