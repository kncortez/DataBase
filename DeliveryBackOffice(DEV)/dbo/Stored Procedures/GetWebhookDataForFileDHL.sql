
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
			SELECT 'H' [Type], GETDATE() [Date_Time], 'Forza' [Partner];
			--Detalle del archivo
			SELECT  'D' [Type], 
					ROW_NUMBER() OVER(ORDER BY [WTQDFS].[ExternalPieceId] DESC) AS [Counter], 
					'IST' [Service_Area_Code], 
					'CET' [Facility_Code], 
					FORMAT(DOP.DateRegistrationExternalCode,'yyyyMMdd') [CheckPointDate],
					FORMAT(DOP.DateRegistrationExternalCode,'hhmmss') [CheckPointTime],
					'-06:00' [GTM_Offset],
					WTQDFS.[ExternalNumber] [Waybill],
					WTQDFS.[ExternalPieceId][PieceId],
					CASE WHEN WTQDFS.[StatusOrderId] = 5 THEN 'OK' ELSE 'FD' END [CheckPointCode],
					CASE WHEN WTQDFS.[StatusOrderId] = 5 THEN DO.Receiver_Alternant_FullName 
						 WHEN WTQDFS.[StatusOrderId] = 2 THEN CONCAT('WC FORZA ' , [WTQDFS].[GuideSerie] , [WTQDFS].[GuideNumber] , '-' , [WTQDFS].[GuidePiece])
						 ELSE '' END [DHL_Checkpoint_Remark],
					'GTW7' [Route_Code],
					'A' [Cycle_Code]
			FROM	
					[DeliveryBackOffice].[dbo].[WebhookTrackingQueueDetailForSFTP] WTQDFS WITH(NOLOCK)
					LEFT JOIN  [DeliveryBackOffice].[dbo].[WebhookTrackingQueueForSFTP] WTQFS WITH(NOLOCK)
						   ON [WTQDFS].[CustomerId] = @CUSTOMER_ID
						  AND [WTQDFS].[WebhookTrackingQueueForSFTPId] = [WTQFS].[IdWebhookTrackingQueueForSFTP]
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					       ON  [WTQDFS].GuideNumber = [DO].Guide_Number
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)	
						   ON [DOP].[GuideNumber] = [DO].Guide_Number
						  AND [DOP].[GuideSerie] = [DO].Guide_Serie
						  AND [WTQDFS].ExternalPieceId = [DOP].ExternalPieceId
					INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] QE WITH(NOLOCK)
						   ON [WTQDFS].[CustomerId] = [QE].[CustomerId]
			WHERE	
					[WTQDFS].[WebhookTrackingQueueForSFTPId] = @LOTE
					
					
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