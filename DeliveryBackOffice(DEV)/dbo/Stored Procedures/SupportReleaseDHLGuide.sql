

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2023-08-20>
-- Description:	<--ESTE SCRIPT SOLO REVERTIRA LA ASIGNACIÓN SI CUMPLE CON LAS SIGUIENTES CONDICIONES--
	--1. Debe de estar anulado
	--2. No debe de tener ningun estado PENDIENTE a notificar en la tabla WebhookTrackingQueueDetailForSFTP>
-- =============================================
CREATE PROCEDURE [dbo].[SupportReleaseDHLGuide]

	 @GuideSerie NVARCHAR(4)='FD',
     @GuideNumber int=9200115	
	AS
BEGIN

	Declare @IsGuideCanceled bit=0;
	select @IsGuideCanceled =1  from DeliveryOrder 
	WHERE [Guide_Number] = @GuideNumber
							AND [Guide_Serie] = @GuideSerie
							AND StatusOrderId in (7,14)

	DECLARE @ExistInQuequeSFTP bit = 0
	--select @ExistInQuequeSFTP=1 from WebhookTrackingQueueDetailForSFTP
	--where guideNumber=@GuideNumber

	select  @ExistInQuequeSFTP=1 from dbo.WebhookTrackingQueueDetailForSFTP wtqdet
		inner join dbo.WebhookTrackingQueueForSFTP wtqd
			on wtqdet.WebhookTrackingQueueForSFTPId= wtqd.idWebhookTrackingQueueForSFTP
	where guidenumber=@GuideNumber
	and hasnotified=0

	select @IsGuideCanceled 

	IF @IsGuideCanceled =0
	BEGIN
		SELECT 'ERROR: La guía NO esta en estado anulado o devuelto'
	END
	ELSE IF @ExistInQuequeSFTP=1
	BEGIN
		SELECT 'ERROR: La guía ya tiene estados notificados o por notificar en cola (tabla WebhookTrackingQueueDetailForSFTP)'
	END
	ELSE
	BEGIN 

							UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder]
							SET [Ticket_Number] = NULL
							WHERE [Guide_Number] = @GuideNumber
							AND [Guide_Serie] = @GuideSerie
							--AND StatusOrderId in (7,14)

						-- Realizar el insert para la pieza Externa con Forza
							UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
							SET [ExternalPieceId] = NULL
							, [TokenRegistrationExternalCode] = NULL
							, [DateRegistrationExternalCode] = NULL
							, [AccountIdRegistrationExternalCode] = NULL
							WHERE [GuideNumber] = @GuideNumber
							AND [GuideSerie] = @GuideSerie 
							--AND [NoPiece] = @NoPiece
							--AND StatusOrderId in (7,14)
		SELECT 'CORRECTO: La guía si esta en un estado aceptable, y no tiene notificaciones pendientes en la cola. Modificación realizada'
		
	END

							
END