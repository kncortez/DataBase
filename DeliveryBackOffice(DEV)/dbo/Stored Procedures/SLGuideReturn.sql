/* =================================================
   SP:        [dbo].[SLGuideReturn]
   Propósito: Proceso encargado de registrar la devolución de guías en Smart Locker cuando un destinatario no recoja su paquete.
   Autor:     Walter Orozco
   Historia:  FDAPI-4827 [FDAPI-4833]
   Fecha:     2025-10-24
=================================================*/

CREATE PROCEDURE [dbo].[SLGuideReturn]
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

		DECLARE @GuideReceptionInSL INT = 
		( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Paquete en Smart Locker' );

		-- Verificar estado
		IF (@Status <> @GuideReceptionInSL)
		BEGIN
			SELECT
				  500													[IdResult]
				, 'La guía se encuentra en un estado no permitido.'		[Message]
			RETURN;
		END;

		-- =====================================================================================================================
		-- =============================================== INICIA PROCESO PARA LA GUÍA =========================================
		-- =====================================================================================================================

		BEGIN TRANSACTION;

		DECLARE @StatusDeclareReturned INT =
        ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WITH (NOLOCK) WHERE OrderDescription = 'Declarado para Devolución' );

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

		-- Activar guía para devolución y asignar estado de "Declarado para devolución"
        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET 
		      IsLastMileReturn = 1
            , StatusOrderId = @StatusDeclareReturned
            , TokenUpdated = @Token
            , DateUpdated = GETDATE()
        WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;

		-- Insertar registro del detalle de la orden 
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
            , @StatusDeclareReturned
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
			('SLGuideReturn', ERROR_MESSAGE(), ERROR_LINE(), ERROR_NUMBER(), @Token, GETDATE(), @GuideSerie, @GuideNumber);
	END CATCH;
END;