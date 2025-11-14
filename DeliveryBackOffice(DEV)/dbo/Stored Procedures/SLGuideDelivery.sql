/* =================================================
   SP:        [dbo].[SLGuideDelivery]
   Propósito: Proceso encargado de registrar la entrega de una guía en Smart Locker cuando un destinatario recoja su paquete.
   Autor:     Walter Orozco
   Historia:  FDAPI-4827 [FDAPI-4832]
   Fecha:     2025-11-10
=================================================*/

CREATE PROCEDURE [dbo].[SLGuideDelivery]
	@GuideSerie		NVARCHAR(2)		= NULL,
	@GuideNumber	INT				= 0,
	@TicketNumber	NVARCHAR(300)	= NULL,
	@Token			NVARCHAR(100)	= 'SYS-SYSTEM'
AS
BEGIN
	BEGIN TRY
		-- Variables
		DECLARE @Status INT = 0;

		-- Referencia
		IF (@TicketNumber IS NOT NULL AND @GuideNumber <= 0)
		BEGIN
			SELECT
				 @GuideSerie  = Guide_Serie
				,@GuideNumber = Guide_Number
				,@Status      = StatusOrderId
			FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
			WHERE Ticket_Number = @TicketNumber
		END;

		IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)
		BEGIN
			SELECT
				  500																										[IdResult]
				, 'La guía ingresada no existe, por favor intente de nuevo, en caso persista contacte al Administrador.'	[Message]
			RETURN;
		END;

		IF (@Status <= 0)
		BEGIN
			SET @Status =  ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) 
                             WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber );
		END;

		-- Estados permitidos para entrega de Smart Locker
		DECLARE @SLGuideReception INT = ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder			WITH(NOLOCK) 
									  WHERE [OrderDescription] = 'Paquete en Smart Locker' );

		-- Verificar estado
		IF (@Status NOT IN (@SLGuideReception))
		BEGIN
			SELECT
				  500																														[IdResult]
				, 'La guía se encuentra en un estado no permitido, asegurese de que se encuentre el paquete recibido en Smart Locker.'		[Message]
			RETURN;
		END;

		-- =====================================================================================================================
		-- =============================================== INICIA PROCESO PARA LA GUÍA =========================================
		-- =====================================================================================================================

		BEGIN TRANSACTION;

		DECLARE @GuideDeliveryInSL INT = 
		( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) WHERE [OrderDescription] = 'Entregado en Smart Locker' );

		DECLARE @StationId INT = 
		(
			SELECT 
				CT.IdStation 
			FROM DeliveryBackOffice.dbo.DeliveryOrder			DO	WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.VisitPointClient	VPC WITH(NOLOCK) 
				ON VPC.CodeOfReference = DO.Receiver_ID
			INNER JOIN DeliveryBackOffice.dbo.CatStation		CT	WITH(NOLOCK)
				ON CT.CodeOfReference = VPC.CodeOfReference
			WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
		);

		-- Actualizar entrega de la orden
        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET StatusOrderId = @GuideDeliveryInSL, DateUpdated = GETDATE(), TokenUpdated = @Token
        WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;

		-- Insertar entrega del detalle de la orden 
        INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
        (
              [Guide_Serie]
            , [Guide_Number]
            , [StatusOrderId]
            , [UserCreated]
            , [DateCreated]
            , [DateCreatedInSystem]
            , [Observations]
            , [Temperature_Celsius]
            , [PieceId]
            , [RowStatus]
			, [SystemOrigin]
			, [StationId]
        )
        VALUES 
		( 
			  @GuideSerie
            , @GuideNumber
            , @GuideDeliveryInSL
            , @Token
            , GETDATE()
            , GETDATE()
            , NULL
            , NULL
            , NULL
            , 1
			, 8 --API
			, @StationId
        );
    
		COMMIT TRANSACTION;

		SELECT
				  200									[IdResult]
				, 'Guía procesada exitosamente.'		[Message]

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
			(ErrorProcedure, ErrorDescription, ErrorLine, ErrorNumber, TokenCreated, DateCreated, GuideSerie, GuideNumber)
		VALUES
			('SLGuideDelivery', ERROR_MESSAGE(), ERROR_LINE(), ERROR_NUMBER(), @Token, GETDATE(), @GuideSerie, @GuideNumber);
	END CATCH;
END;