/* =================================================
   SP:        [dbo].[SLGuideReception]
   Propósito: Proceso encargado de registrar la recepción de una guía en Smart Locker entregado por un piloto.
   Autor:     Walter Orozco
   Historia:  FDAPI-4827 [FDAPI-4831]
   Fecha:     2025-10-23
=================================================*/

CREATE PROCEDURE [dbo].[SLGuideReception]
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

		-- Estados permitidos para registro de Smart Locker
		DECLARE @GuideInRoute INT = ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder			WITH(NOLOCK) 
									  WHERE [OrderDescription] = 'En ruta' );

		DECLARE @GuideInReturnRoute INT = ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder	WITH(NOLOCK) 
											WHERE [OrderDescription] = 'En ruta para devolución' );

		DECLARE @IncidenceInRoute INT = ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder		WITH(NOLOCK) 
										  WHERE [OrderDescription] = 'Incidencia en ruta' );

		DECLARE @FailedDeliveryAttempt INT = ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) 
										  WHERE [OrderDescription] = 'Incidencia Validada' );

		-- Verificar estado
		IF (@Status IN (@GuideInRoute,@GuideInReturnRoute,@IncidenceInRoute,@FailedDeliveryAttempt) 
			AND @Status NOT IN ( SELECT StatusOrderId FROM dbo.StatusOrder SO  WITH(NOLOCK) WHERE CatCheckpointTypeId = 3 ))
		BEGIN
			SELECT
				  500																										[IdResult]
				, 'La guía se encuentra en un estado no permitido, asegurese de que se encuentre asignada a una ruta.'		[Message]
			RETURN;
		END;

		-- =====================================================================================================================
		-- =============================================== INICIA PROCESO PARA LA GUÍA =========================================
		-- =====================================================================================================================

		BEGIN TRANSACTION;

		DECLARE @GuideReceptionInSL INT = 
		( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) WHERE [OrderDescription] = 'Paquete en Smart Locker' );

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

		-- Actualizar registro de la orden
        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET StatusOrderId = @GuideReceptionInSL
        WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;

		-- Actualizar registros del detalle de manifiestos de entrega
		UPDATE DSD
        SET 
			  RowStatus     = 0
            , TokenUpdated  = @Token
            , DateUpdated   = GETDATE()
			, StatusOrderId = @GuideReceptionInSL
        FROM DeliveryBackOffice.dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOBS WITH (NOLOCK)
			ON DSD.ID_DeliveryOrderBySettlement = DOBS.ID
		WHERE DSD.RowStatus = 1 AND DSD.Guide_Serie = @GuideSerie AND DSD.Guide_Number = @GuideNumber
		AND CAST(DOBS.Date_Dispatched AS DATE) = CAST(GETDATE() AS DATE);

		UPDATE RPD 
		SET
			  RowStatus    = 0
			, TokenUpdated = @Token
			, DateUpdated  = GETDATE()
		FROM DeliveryBackOffice.dbo.RoutePreparationDetail RPD WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.RoutePreparation RP WITH (NOLOCK)
			ON RPD.RoutePreparationId = RP.IdRoutePreparation
		WHERE RPD.RowStatus = 1 AND RPD.Guide_Serie = @GuideSerie AND RPD.Guide_Number = @GuideNumber
		AND RP.DateRoutePreparation = CAST(GETDATE() AS DATE);

		-- Actualizar registros del detalle de servicios de devolución
        UPDATE STD
        SET 
			  STD.RowStatus     = 0
            , STD.TokenUpdated  = @Token
            , STD.DateUpdated   = GETDATE()
        FROM dbo.SettlementByPickup STP WITH (NOLOCK)
            LEFT JOIN dbo.SettlementByPickupDetail STD WITH (NOLOCK)
                ON STD.SettlementByPickupId = STP.Id AND STD.RowStatus = 1
            LEFT JOIN dbo.DeliveryOrderPiece DPC WITH (NOLOCK)
                ON DPC.GuideSerie = STD.GuideSerie AND DPC.GuideNumber = STD.GuideNumber
            LEFT JOIN dbo.PieceByService PBS WITH (NOLOCK)
                ON PBS.GuidePieceId = DPC.GuidePiece
            LEFT JOIN dbo.ServiceManagement SMG WITH (NOLOCK)
                ON SMG.IdServiceManagement = PBS.ServiceManagmentId
        WHERE SMG.SubTypeServiceManagmentId = 3 AND STD.GuideSerie = @GuideSerie AND STD.GuideNumber = @GuideNumber;

		UPDATE PBS
        SET 
			  PBS.RowStatus = 0
            , PBS.TokenUpdated = @Token
            , PBS.DateUpdated = GETDATE()
        FROM dbo.SettlementByPickup STP WITH (NOLOCK)
            LEFT JOIN dbo.SettlementByPickupDetail STD WITH (NOLOCK)
                ON STD.SettlementByPickupId = STP.Id AND STD.RowStatus = 1
            LEFT JOIN dbo.DeliveryOrderPiece DPC WITH (NOLOCK)
                ON DPC.GuideSerie = STD.GuideSerie AND DPC.GuideNumber = STD.GuideNumber
            LEFT JOIN dbo.PieceByService PBS WITH (NOLOCK)
                ON PBS.GuidePieceId = DPC.GuidePiece
            LEFT JOIN dbo.ServiceManagement SMG WITH (NOLOCK)
                ON SMG.IdServiceManagement = PBS.ServiceManagmentId
        WHERE SMG.SubTypeServiceManagmentId = 3 AND STD.GuideSerie = @GuideSerie AND STD.GuideNumber = @GuideNumber;

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
            , @GuideReceptionInSL
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
			('SLGuideReception', ERROR_MESSAGE(), ERROR_LINE(), ERROR_NUMBER(), @Token, GETDATE(), @GuideSerie, @GuideNumber);
	END CATCH;
END;