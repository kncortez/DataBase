
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
		PRINT '-- CREACION DE LOTE  --'
		SELECT @HOSTNAME = wep.Hostname FROM WebhookEndpoint wep WHERE wep.CustomerId = @CUSTOMER_ID;

		IF (@HOSTNAME <> '') 
		BEGIN
			--Definir el nombre del archivo
			SET @FILENAME = CONCAT('GT_FORZA_',FORMAT(GETDATE(),'yyyyMMdd_hhmmss'),'.txt');
			
			INSERT INTO WebhookTrackingQueueForSFTP ([FileName], [Hostname], [HasNotified], [RowStatus], [TokenCreated], [DateCreated])
			VALUES(@FILENAME, @HOSTNAME,0,1,'SYS-CAZURDIA',GETDATE());

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
		PRINT '-- ASIGNACIÓN DE GUIAS A LOTE GENERADO --'

		-- Guias no asignadas 
		UPDATE WebhookTrackingQueueDetailForSFTP SET WebhookTrackingQueueForSFTPId = @LOTE WHERE WebhookTrackingQueueForSFTPId IS NULL 
		-- Guias pendientes de asignar
		UPDATE WebhookTrackingQueueDetailForSFTP
		SET WebhookTrackingQueueDetailForSFTP.WebhookTrackingQueueForSFTPId = @LOTE 
		FROM WebhookTrackingQueueDetailForSFTP 
			LEFT JOIN WebhookTrackingQueueDetailPendingForSFTP 
			   ON WebhookTrackingQueueDetailForSFTP.IdWebhookTrackingQueueDetailForSFTP = WebhookTrackingQueueDetailPendingForSFTP.IdWebhookTrackingQueueDetailPendingForSFTP
			   AND WebhookTrackingQueueDetailForSFTP.WebhookTrackingQueueForSFTPId = WebhookTrackingQueueDetailPendingForSFTP.WebhookTrackingQueueForSFTPId
			LEFT JOIN WebhookTrackingQueueForSFTP
			   ON WebhookTrackingQueueDetailForSFTP.WebhookTrackingQueueForSFTPId = WebhookTrackingQueueForSFTP.IdWebhookTrackingQueueForSFTP
		WHERE WebhookTrackingQueueForSFTP.HasNotified = 0;

		SELECT '202' [status], 'Acción Creacion de lote' [message];

	END
	ELSE IF(@T_TYPE = 3)
	BEGIN
		PRINT '-- GENERACIÓN DE ARCHIVO QUE SE ENVIARA A FORZA --'
		-- Verificar si el lote existe
		IF EXISTS( Select IdWebhookTrackingQueueForSFTP from WebhookTrackingQueueForSFTP WHERE IdWebhookTrackingQueueForSFTP = @LOTE )
		BEGIN 

			--Encabezado del archivo
			SELECT 'H' [Type], GETDATE() [Date_Time], 'FORZA' [Partner];

			--Datos base del detalle
			WITH D as (
			SELECT  'D' [Type], 
					ROW_NUMBER() OVER(ORDER BY [WTQDFS].[ExternalPieceId] DESC) AS [Counter], 
					'IST' [Service_Area_Code], 
					'CET' [Facility_Code], 
					FORMAT(ISNULL(DOP.DateRegistrationExternalCode,'1900-01-01 00:00:00'),'yyyyMMdd') [CheckPointDate],
					FORMAT(ISNULL(DOP.DateRegistrationExternalCode,'1900-01-01 00:00:00'),'HHmmss') [CheckPointTime],
					'-06:00' [GTM_Offset],
					WTQDFS.[GuideSerie],
					WTQDFS.[GuideNumber],
					WTQDFS.[GuidePiece],
					WTQDFS.[ExternalNumber] [Waybill],
					WTQDFS.[ExternalPieceId][PieceId],
					CASE WHEN [WTQDFS].[StatusOrderId] = 5 THEN 'OK' WHEN [WTQDFS].[StatusOrderId] = 22 THEN 'OK' ELSE 'FD' END [CheckPointCode],
					WTQDFS.StatusOrderId [DHL_Status],
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
			DSO AS( --Obtener detalle del estatus
				SELECT  [D].[PieceId], 
						[D].[Waybill], 
						[D].[DHL_Status],
					    CASE WHEN [SOE].IdStatusOrderExternal = 1
							 THEN CONCAT([SOE].[Remark],'FORZA ',D.GuideSerie,D.GuideNumber,'-',D.GuidePiece)
							 WHEN [SOE].IdStatusOrderExternal = 2
							 THEN CONCAT([SOE].[Remark],'FORZA ')
							 WHEN [SOE].IdStatusOrderExternal = 6
							 THEN CONCAT([SOE].[Remark],'FORZA ')
							 WHEN [SOE].IdStatusOrderExternal = 9
							 THEN CONCAT([SOE].[Remark], ' ' ,[DO].NameOfReceiver)
							 ELSE [SOE].[Remark]
							 END [DHL_Checkpoint_Remark_DSO]
				FROM D
				LEFT JOIN [dbo].[StatusOrderRelation] SOR
					ON [SOR].[StatusOrderId] = [D].[DHL_Status]
				LEFT JOIN [dbo].[StatusOrderExternal] SOE
					ON [SOE].[IdStatusOrderExternal] = [SOR].[StatusOrderExternalId]
				INNER JOIN [dbo].[DeliveryOrder] DO
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
					    CASE WHEN [SOE].IdStatusOrderExternal = 4
							 THEN CONCAT([SOE].[Remark],'FORZA ')
							 ELSE [SOE].[Remark]
							 END [DHL_Checkpoint_Remark_DI]
				FROM D
				RIGHT JOIN [dbo].[DeliveryAttempt] DA
					ON [DA].[Guide_Serie] = [D].[GuideSerie]
					AND [DA].[Guide_Number] = [D].[GuideNumber]
					AND [DA].[Guide_Piece] = [D].[GuidePiece]
				LEFT JOIN [dbo].[ConfirmationOfIncidence] COI
					ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
				LEFT JOIN [dbo].[IncidentTypeRelation] ITR
					ON [ITR].[IncidenceTypeId] = [COI].[CatTypeConfirmationOfIncidenceId]
			   LEFT JOIN [dbo].[StatusOrderExternal] SOE
					ON [SOE].[IdStatusOrderExternal] = [ITR].[StatusOrderExternalId]
				WHERE D.DHL_Status = 50
				  AND [COI].[RowStatus] = 1
				  --AND [SOE].[CustomerId] = @CUSTOMER_ID
			)
			
			--SELECT * FROM D;
			--Detalle del archivo
			SELECT	D.[Type], 
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
					D.[Route_Code],
					D.[Cycle_Code]
			FROM D
			ORDER BY [Counter] ASC
			
			--Pie de página del archivo
			SELECT 'T' [Type], COUNT(IdWebhookTrackingQueueDetailForSFTP) [Total_Pieces] 
			FROM WebhookTrackingQueueDetailForSFTP
			WHERE [WebhookTrackingQueueForSFTPId] = @LOTE;

		END
		ELSE 
		BEGIN
			Select '404' [status], 'Lote No Existente' [message];
		END
	END
	ELSE IF (@T_TYPE = 4)
	BEGIN
		PRINT '-- ACTUALIZACION DEL ESTATUS DEL LOTE ESPECIFICADO --'

		IF(@MESSAGE = '')
		BEGIN
			PRINT '-- ARCHIVO ACEPTADO --'
		-- Se actualiza encabezado y deja constancia de que concluyo la entrega del archivo
			UPDATE WebhookTrackingQueueForSFTP 
			SET		HasNotified = 1, 
					SenderResponse = 'OK', 
					RegistrationDate = GETDATE(),
					TokenUpdated = 'SYST-CAZURDIA',
					DateUpdated = GETDATE()
			WHERE IdWebhookTrackingQueueForSFTP = @LOTE;

		-- Se actualiza encabezados pendientes y que se concluyeron en la entrega del archivo
			UPDATE WebhookTrackingQueueDetailPendingForSFTP 
			SET		TokenUpdated = 'SYST-CAZURDIA',
					DateUpdated = GETDATE()
			FROM  WebhookTrackingQueueDetailPendingForSFTP WITH(NOLOCK)
			LEFT JOIN WebhookTrackingQueueDetailForSFTP WTQDFS WITH(NOLOCK)
				  ON  WebhookTrackingQueueDetailPendingForSFTP.IdWebhookTrackingQueueDetailPendingForSFTP = WTQDFS.IdWebhookTrackingQueueDetailForSFTP
				   AND WebhookTrackingQueueDetailPendingForSFTP.WebhookTrackingQueueForSFTPId = WTQDFS.WebhookTrackingQueueForSFTPId
			INNER JOIN WebhookTrackingQueueForSFTP WTQFS WITH(NOLOCK)
			      ON  WebhookTrackingQueueDetailPendingForSFTP.WebhookTrackingQueueForSFTPId = WTQFS.IdWebhookTrackingQueueForSFTP
			WHERE 
				 WTQFS.HasNotified = 0
			
			UPDATE WebhookTrackingQueueForSFTP 
			SET		HasNotified = 1,
				    TokenUpdated = 'SYST-CAZURDIA',
					DateUpdated = GETDATE()
			FROM   WebhookTrackingQueueForSFTP  WITH(NOLOCK)
			INNER JOIN WebhookTrackingQueueDetailPendingForSFTP WTQDPFS WITH(NOLOCK)
				   ON WebhookTrackingQueueForSFTP.IdWebhookTrackingQueueForSFTP = WTQDPFS.WebhookTrackingQueueForSFTPId
			LEFT JOIN WebhookTrackingQueueDetailForSFTP WTQDFS WITH(NOLOCK)
				   ON  WTQDFS.WebhookTrackingQueueForSFTPId = WebhookTrackingQueueForSFTP.IdWebhookTrackingQueueForSFTP
				  AND  WTQDFS.IdWebhookTrackingQueueDetailForSFTP = WTQDPFS.IdWebhookTrackingQueueDetailPendingForSFTP

			Select '202' [status], 'Lote Estatus Actualizado' [message];
		END
		ELSE
		BEGIN
			PRINT '-- ARCHIVO PENDIENTE --'
			-- Se actualiza encabezado y deja constancia del porque no se concluyo la entrega del archivo
			UPDATE WebhookTrackingQueueForSFTP 
			SET		HasNotified = 0, 
					SenderResponse = @MESSAGE, 
					RegistrationDate = GETDATE() 
			WHERE IdWebhookTrackingQueueForSFTP = @LOTE;

			-- Se actualiza encabezado y deja constancia del porque no se concluyo la entrega del archivo
			INSERT INTO WebhookTrackingQueueDetailPendingForSFTP(WebhookTrackingQueueForSFTPId,IdWebhookTrackingQueueDetailPendingForSFTP,RowStatus,TokenCreated,DateCreated)
			SELECT WebhookTrackingQueueForSFTPId, IdWebhookTrackingQueueDetailForSFTP, 1, 'SYS-CAZURDIA', GETDATE() 
			FROM WebhookTrackingQueueDetailForSFTP 
			WHERE WebhookTrackingQueueForSFTPId = @LOTE;

			Select '202' [status], 'Lote Estatus Actualizado' [message];
		END

	END
	ELSE 
	BEGIN
		Select '404' [status], 'Acción No definida' [message];
	END

END