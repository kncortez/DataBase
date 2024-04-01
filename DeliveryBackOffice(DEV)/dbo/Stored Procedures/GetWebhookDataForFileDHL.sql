
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
	DECLARE @PIECEID VARCHAR(50);
	/***************************************************************************
	************* EVALUAR QUE TIPO DE ACCIÓN SE VA A REALIZAR ******************
	****************************************************************************/

	--SET @CUSTOMER_ID = 24;
	--SET @PIECEID = 'JD01460001132';

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
		UPDATE [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP] 
		SET [WebhookTrackingQueueForSFTPId] = @LOTE 
		WHERE  [CustomerId] = @CUSTOMER_ID 
		   AND [WebhookTrackingQueueForSFTPId] IS NULL
		-- Guias con problemas y pendientes de asignar
		UPDATE [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP]
		SET [WebhookTrackingQueueDetailForSFTP].[WebhookTrackingQueueForSFTPId] = @LOTE 
		FROM [WebhookTrackingQueueDetailForSFTP] WITH (NOLOCK)
			LEFT JOIN  [DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailPendingForSFTP]
			   ON [WebhookTrackingQueueDetailForSFTP].[IdWebhookTrackingQueueDetailForSFTP] = [WebhookTrackingQueueDetailPendingForSFTP].[IdWebhookTrackingQueueDetailPendingForSFTP]
			   AND [WebhookTrackingQueueDetailForSFTP].[WebhookTrackingQueueForSFTPId] = [WebhookTrackingQueueDetailPendingForSFTP].[WebhookTrackingQueueForSFTPId]
			LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP]
			   ON [WebhookTrackingQueueDetailForSFTP].[WebhookTrackingQueueForSFTPId] = [WebhookTrackingQueueForSFTP].[IdWebhookTrackingQueueForSFTP]
		WHERE	[WebhookTrackingQueueDetailForSFTP].[CustomerId] = @CUSTOMER_ID 
			AND	[WebhookTrackingQueueForSFTP].[HasNotified] = 0;

		SELECT '202' [status], 'Acción Creacion de lote' [message];

	END
	ELSE IF(@T_TYPE = 3)
	BEGIN

		--PRINT '-- GENERACIÓN DE ARCHIVO QUE SE ENVIARA A FORZA --'
		-- Verificar si el lote existe
		IF EXISTS( Select [IdWebhookTrackingQueueForSFTP] from [dbo].[WebhookTrackingQueueForSFTP] WHERE [RowStatus] = 1 AND [IdWebhookTrackingQueueForSFTP] = @LOTE AND [HasNotified] = 0 )
		BEGIN 

			--Encabezado del archivo
			SELECT 'H' [Type], GETDATE() [Date_Time], 'FORZA' [Partner];

			DECLARE @WebhookTrackingQuequeLoteDetailforSFTP AS TABLE (
					[idWebhookTrackingQuequeLoteDetailforSFTP] INT NOT NULL PRIMARY KEY,
					[Type] NVARCHAR(8) NOT NULL,
					[Counter] INT NOT NULL,
					[Service_Area_Code] NVARCHAR(8) NOT NULL,
					[Facility_Code] NVARCHAR(8) NOT NULL,
					[CheckPointDate] NVARCHAR(10) NOT NULL,
					[CheckPointTime] NVARCHAR(10) NOT NULL,
					[GTM_Offset] NVARCHAR(6) NOT NULL,
					[GuideSerie] NVARCHAR(8) NOT NULL,
					[GuideNumber] NVARCHAR(8) NOT NULL,
					[GuidePiece] INT NOT NULL,
					[Waybill] BIGINT NOT NULL,
					[PieceId] NVARCHAR(32) NOT NULL,
					[CheckPointCode] NVARCHAR(4) NOT NULL,
					[DHL_Checkpoint_Remark] NVARCHAR(32) NOT NULL,
					[Route_Code] NVARCHAR(4) NOT NULL,
					[Cycle_Code] NVARCHAR(4) NOT NULL,
					[TokenCreated] NVARCHAR(64) NOT NULL,
					[DHL_Status] INT NOT NULL,
					[DHL_Incident] INT NULL,
					[NewDeliveryDate] Datetime NULL
			);

			DECLARE @WebhookTrackingQuequeLoteStationsforSFTP AS TABLE (
					[idWebhookTrackingQuequeLoteDetailforSFTP] INT NOT NULL PRIMARY KEY,
					[Station] NVARCHAR(64) NOT NULL);

			INSERT INTO @WebhookTrackingQuequeLoteDetailforSFTP([idWebhookTrackingQuequeLoteDetailforSFTP],
																[Type],
																[Counter],
																[Service_Area_Code],
																[Facility_Code],
																[CheckPointDate],
																[CheckPointTime],
																[GTM_Offset],
																[GuideSerie],
																[GuideNumber],
																[GuidePiece],
																[Waybill],
																[PieceId],
																[CheckPointCode],
																[DHL_Checkpoint_Remark],
																[Route_Code],
																[Cycle_Code],
																[TokenCreated],
																[DHL_Status],
																[DHL_Incident],
																[NewDeliveryDate])
			SELECT  [WTQDFS].[IdWebhookTrackingQueueDetailForSFTP],
					'D' [Type], 
					--ROW_NUMBER() OVER(ORDER BY [WTQDFS].[IdWebhookTrackingQueueDetailForSFTP] ASC) AS [Counter], 
					ROW_NUMBER() OVER(ORDER BY [WTQDFS].[DateCreated] ASC) AS [Counter], 
					'GTL' [Service_Area_Code], 
					'GTL' [Facility_Code], 
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
					CASE WHEN [WTQDFS].[StatusOrderId] = 5 THEN 'OK' WHEN [WTQDFS].[StatusOrderId] = 22 THEN 'OK' ELSE 'FD' END [CheckPointCode],
					'' [DHL_Checkpoint_Remark],
					'GTW7' [Route_Code],
					'A' [Cycle_Code],
					WTQDFS.[TokenCreated],
					WTQDFS.[StatusOrderId] [DHL_Status],
					WTQDFS.[DeliveryAttemptId] [DHL_Incident],
					WTQDFS.[NewDeliveryDate]				
			FROM	[DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP] WTQDFS WITH(NOLOCK)
			WHERE	[WTQDFS].[CustomerId] = @CUSTOMER_ID
				AND	[WTQDFS].[WebhookTrackingQueueForSFTPId] = @LOTE
				AND [WTQDFS].RowStatus = 1
				--AND [WTQDFS].[ExternalPieceId] = @PIECEID
			
		   INSERT INTO @WebhookTrackingQuequeLoteStationsforSFTP(
																[idWebhookTrackingQuequeLoteDetailforSFTP],
																[Station])
			
			SELECT A1.[idWebhookTrackingQuequeLoteDetailforSFTP], 
				  ISNULL(A7.DescriptionOfClient,'') [Station]
			FROM @WebhookTrackingQuequeLoteDetailforSFTP A1
			INNER JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken] A2 WITH (NOLOCK)
						ON CAST(A1.[TokenCreated] AS VARCHAR(50)) = A2.[SSN_IdToken]
			INNER JOIN [DeliveryBackOffice].[dbo].[InternalUser] A3 WITH (NOLOCK)
						ON A2.[SSN_IdUser] = A3.[IdUser]
						   AND A2.[SSN_Username] = CAST(A3.[Username] AS VARCHAR(50))
			OUTER APPLY
			(
				SELECT TOP 1 [A4].[StationId]
				FROM [DeliveryBackOffice].[dbo].[RolByUserBySystem] A4 WITH (NOLOCK)
				WHERE A4.[RusIdUser] = A3.[RegisterUserID]
						AND [StationId] IS NOT NULL
				ORDER BY StationId
			) A5
			INNER JOIN [dbo].[CatStation] A6 WITH (NOLOCK)
				ON A5.[StationId] = A6.[IdStation]
			INNER JOIN [dbo].[VisitPointClient] A7 WITH (NOLOCK)
				ON A7.[CodeOfReference] = A6.[CodeOfReference]

			--Select * from @WebhookTrackingQuequeLoteDetailforSFTP
			--Select * from @WebhookTrackingQuequeLoteStationsforSFTP

			--Detalle del archivo Final
			SELECT D.[Type], 
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
					D. [DHL_Checkpoint_Remark],
					--'ERROR' [DHL_Checkpoint_Remark],
					D.[Route_Code],
					D.[Cycle_Code] 
			FROM
			(
				SELECT  [D1].[Type],
						[D1].[Counter],
						[D1].[Service_Area_Code],
						[D1].[Facility_Code],
						[D1].[CheckPointDate],
						[D1].[CheckPointTime],
						[D1].[GTM_Offset],
						[D1].[Waybill],
						[D1].[PieceId],
						[D1].[CheckPointCode],
					    CASE WHEN [SOE].[IdStatusOrderExternal] = 1  --Recolecta
							 THEN CONCAT([SOE].[Remark],'FORZA ',[D1].[GuideSerie],[D1].[GuideNumber],'-',[DOP].[NoPiece])
							 WHEN [SOE].IdStatusOrderExternal = 2  --Arrivo
							 THEN CONCAT([SOE].[Remark],'FORZA ', (
																	SELECT   STUFF([S].[Station], CHARINDEX('FD EXC', [S].[Station]), LEN('FD EXC') + CASE WHEN SUBSTRING([S].[Station], CHARINDEX('FD EXC', [S].[Station]) + LEN('FD EXC'), 1) = ' ' THEN 1 ELSE 0 END,  '')
																	--SELECT [S].[Station] 
																	FROM @WebhookTrackingQuequeLoteStationsforSFTP  S 
																	WHERE [D1].[idWebhookTrackingQuequeLoteDetailforSFTP] = [S].[idWebhookTrackingQuequeLoteDetailforSFTP] )
																  )
							 WHEN [SOE].IdStatusOrderExternal = 6  --Inventario
							 THEN CONCAT([SOE].[Remark],'FORZA ', (
																	SELECT   STUFF([S].[Station], CHARINDEX('FD EXC', [S].[Station]), LEN('FD EXC') + CASE WHEN SUBSTRING([S].[Station], CHARINDEX('FD EXC', [S].[Station]) + LEN('FD EXC'), 1) = ' ' THEN 1 ELSE 0 END,  '')
																	FROM @WebhookTrackingQuequeLoteStationsforSFTP  S 
																	WHERE [D1].[idWebhookTrackingQuequeLoteDetailforSFTP] = [S].[idWebhookTrackingQuequeLoteDetailforSFTP] )
																  )
							 WHEN [SOE].IdStatusOrderExternal = 8  --En Ruta
							 THEN CONCAT([SOE].[Remark],'')
							 WHEN [SOE].IdStatusOrderExternal = 9  --Entrega
							 THEN CONCAT([SOE].[Remark], '',[DO].[NameOfReceiver])
							 ELSE [SOE].[Remark]                   --Todo lo demás
							 END [DHL_Checkpoint_Remark],
						[D1].[Route_Code],
						[D1].[Cycle_Code] 
				FROM @WebhookTrackingQuequeLoteDetailforSFTP D1
				LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrderRelation] SOR WITH (NOLOCK)
					ON [SOR].[StatusOrderId] = [D1].[DHL_Status]
				LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrderExternal] SOE WITH (NOLOCK)
					ON [SOE].[IdStatusOrderExternal] = [SOR].[StatusOrderExternalId]
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
					ON [DO].[Guide_Serie] = [D1].[GuideSerie]
				    AND [DO].[Guide_Number] = [D1].[GuideNumber]
				LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
					ON [DOP].[GuidePiece] = [D1].[GuidePiece]
				WHERE D1.[DHL_Incident] IS NULL
				  AND [SOR].[RowStatus] = 1
				  AND [SOE].[RowStatus] = 1
				  --AND [SOE].[CustomerId] = @CUSTOMER_ID
				UNION ALL
				SELECT  [D2].[Type],
						[D2].[Counter],
						[D2].[Service_Area_Code],
						[D2].[Facility_Code],
						[D2].[CheckPointDate],
						[D2].[CheckPointTime],
						[D2].[GTM_Offset],
						[D2].[Waybill],
						[D2].[PieceId],
						[D2].[CheckPointCode],
						CASE WHEN [SOE].[IdStatusOrderExternal] = 3
							 THEN CONCAT([SOE].[Remark],'')
							 WHEN [SOE].IdStatusOrderExternal = 4
							 THEN CONCAT([SOE].[Remark], ' ', FORMAT(ISNULL([D2].[NewDeliveryDate],'1900-01-01 00:00:00'),'ddMM'), ' PM' )
							 WHEN [SOE].IdStatusOrderExternal = 5
							 THEN CONCAT([SOE].[Remark],'')
							 ELSE [SOE].[Remark]
							 END [DHL_Checkpoint_Remark],
						[D2].[Route_Code],
						[D2].[Cycle_Code] 
				FROM @WebhookTrackingQuequeLoteDetailforSFTP D2
				RIGHT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
					ON [DA].[ID] = [D2].[DHL_Incident]
				LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
					ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
				LEFT JOIN [DeliveryBackOffice].[dbo].[IncidentTypeRelation] ITR WITH (NOLOCK)
					ON [ITR].[IncidenceTypeId] = [DA].[ID_Incident]
				LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrderExternal] SOE WITH (NOLOCK)
					ON [SOE].[IdStatusOrderExternal] = [ITR].[StatusOrderExternalId]
				WHERE [D2].[DHL_Incident] IS NOT NULL
				  AND [COI].[IsConfirmed] = 1
				  AND [COI].[IsDenied] = 0
				  AND [COI].[RowStatus] = 1
				  AND [ITR].[RowStatus] = 1
				  --AND [SOE].[CustomerId] = @CUSTOMER_ID
			)AS D
			ORDER BY D.[Counter] ASC;
	    			
			--Pie de página del archivo
			SELECT	'T' [Type], 
					COUNT(IdWebhookTrackingQueueDetailForSFTP) [Total_Pieces] 
			FROM	[DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP] WITH (NOLOCK)
			WHERE	[WebhookTrackingQueueForSFTPId] = @LOTE
				AND [CustomerId] = @CUSTOMER_ID;
				--AND [ExternalPieceId] = @PIECEID;
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
			WHERE  [WTQDFS].[CustomerId] = @CUSTOMER_ID 
			    AND [WTQFS].[HasNotified] = 0
			
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
			WHERE  [WTQDFS].[CustomerId] = @CUSTOMER_ID 
			   AND [WebhookTrackingQueueForSFTP].[HasNotified] = 0

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
			FROM [dbo].[WebhookTrackingQueueDetailForSFTP]  WITH (NOLOCK)
			WHERE [WebhookTrackingQueueForSFTPId] = @LOTE;

			Select '202' [status], 'Lote Estatus Actualizado' [message];
		END

	END
	ELSE 
	BEGIN
		Select '404' [status], 'Acción No definida' [message];
	END

END