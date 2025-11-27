/* =================================================
   SP:        [dbo].[SLGuideReturnPickUp]
   Propósito: Proceso encargado de registrar el retiro de un paquete para devolución de guías en Smart Locker.
   Autor:     Walter Orozco
   Historia:  FDAPI-4827 [FDAPI-4834]
   Fecha:     2025-11-12
=================================================*/

CREATE PROCEDURE [dbo].[SLGuideReturnPickUp]
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
				  500																								[IdResult]
				, 'Por favor verifica el número e intenta nuevamente. Si el problema persiste, contacta a soporte.'	[Message]
			RETURN;
		END;

		IF (@Status <= 0)
		BEGIN
			SET @Status =  ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) 
                             WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber );
		END;

		-- Estados permitidos para entrega de Smart Locker
		DECLARE @StatusDeclareReturned INT = ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder			WITH(NOLOCK) 
									  WHERE [OrderDescription] = 'Declarado para Devolución' );

		DECLARE @StatusRequired	INT = ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder			WITH(NOLOCK) 
									  WHERE [OrderDescription] = 'Solicitado' );

		-- Verificar estado
		IF (@Status NOT IN (@StatusDeclareReturned,@StatusRequired))
		BEGIN
			SELECT
				  500																			[IdResult]
				, 'Asegúrate de que esté en devolución de smart locker antes de continuar.'		[Message]
			RETURN;
		END;

		-- =====================================================================================================================
		-- =============================================== INICIA PROCESO PARA LA GUÍA =========================================
		-- =====================================================================================================================

		BEGIN TRANSACTION;

		DECLARE @GuideReturnPickUpInSL INT = 
		( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) WHERE [OrderDescription] = 'Retirado en Smart Locker' );

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

		-- Se agrega para dejar registro de 'Retirado en Smart Locker' sin afectar el flujo despues de recoleccion
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
            , @GuideReturnPickUpInSL
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
			('SLGuideReturnPickUp', ERROR_MESSAGE(), ERROR_LINE(), ERROR_NUMBER(), @Token, GETDATE(), @GuideSerie, @GuideNumber);
	END CATCH;
END;