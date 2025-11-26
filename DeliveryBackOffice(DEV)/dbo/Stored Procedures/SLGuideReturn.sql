/* =================================================
   SP:        [dbo].[SLGuideReturn]
   Propósito: Proceso encargado de registrar la devolución de guías en Smart Locker cuando un destinatario no recoja su paquete.
   Autor:     Walter Orozco
   Historia:  FDAPI-4827 [FDAPI-4833]
   Fecha:     2025-10-24
=================================================*/

CREATE PROCEDURE [dbo].[SLGuideReturn]
	@GuideSerie			NVARCHAR(2)		= NULL,
	@GuideNumber		INT				= 0,
	@TicketNumber		NVARCHAR(300)	= NULL,
	@StartDate			DATETIME,
    @EndDate			DATETIME,
	@Token				NVARCHAR(100)	= 'SYS-SYSTEM'
AS
BEGIN
	BEGIN TRY

		-- Variables
		DECLARE @Status INT = 0 , @IdCountry NVARCHAR(3) = NULL;

		-- Referencia
		IF (@TicketNumber IS NOT NULL AND @GuideNumber <= 0)
		BEGIN
			SELECT
				  @GuideSerie  = Guide_Serie
				, @GuideNumber = Guide_Number
				, @Status      = StatusOrderId
				, @IdCountry   = ReceiverCountryId
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
			SELECT
				  @Status		= StatusOrderId
				, @IdCountry    = ReceiverCountryId
			FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) 
            WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
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

		DECLARE @StatusRequired INT =
        ( SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WITH (NOLOCK) WHERE OrderDescription = 'Solicitado' );

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

		-- Activar guía para devolución y asignar estado de "Solicitado" segun flujo de recolección
        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET 
		      IsLastMileReturn = 1
            , StatusOrderId = @StatusRequired
            , TokenUpdated = @Token
            , DateUpdated = GETDATE()
        WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;

		-- Insertar registro del detalle de la orden para "Declarado para Devolución" y para "Solicitado"
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
			@GuideSerie , @GuideNumber , @StatusDeclareReturned , @Token , GETDATE() , GETDATE() , NULL , NULL , NULL , 1 , 8 , @StationId
        ),
		( 
			@GuideSerie , @GuideNumber , @StatusRequired , @Token , GETDATE() , GETDATE() , NULL , NULL , NULL , 1 , 8 , @StationId
        );

		-- Flujo para solicitud de recolección de la guía en estado de declarado para devolución desde un Smart Locker

		DECLARE		@idSender			INT				= NULL,
					@nameSender			NVARCHAR(200)	= NULL,
					@phoneSender		NVARCHAR(50)	= NULL, 
					@TypeVehicle		INT				= NULL,
					@addressPickUp		NVARCHAR(500)	= NULL,
					@idSchedulePickUp	INT				= NULL,
					@quantityRegular	INT				= 1,
					@dopdId				INT				= NULL,
					@idSchedule			INT				= NULL,
					@TotalAmount		DECIMAL(16,2)	= 0.00, 
					@CatPaymentTimeId	INT				= NULL;

		DECLARE @TypeVehicleDefault INT = 
		(	SELECT IdTypeVehicle FROM DeliveryBackOffice.dbo.CatTypeVehicle WITH(NOLOCK) 
			WHERE PackageSize = 'Paquete mediano' AND IdCountry = @IdCountry	);

		SELECT
			  @idSender = DO.Receiver_ID
			, @nameSender = VPC.DescriptionOfClient
			, @phoneSender = VPC.Phone
			, @addressPickUp = VPC.[Address]
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
			ON	DO.Receiver_ID = VPC.CodeOfReference
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber

		SELECT
			  @quantityRegular = COUNT(NoPiece)
			, @TypeVehicle     = ISNULL( MAX(CASE WHEN DOP.NoPiece = 1 THEN CTV.IdTypeVehicle  END), @TypeVehicleDefault )
		FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.CatTypeVehicle CTV WITH(NOLOCK)
		ON  DOP.Detail   = CTV.PackageSize AND CTV.IdCountry = @IdCountry
		WHERE DOP.GuideSerie  = @GuideSerie 
		AND DOP.GuideNumber = @GuideNumber;

		INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickup]
			(
				  StartDate,
				  EndDate,
				  EstimatedWeight,
				  IsLargePackage,
				  QuantityRegularPackages,
				  QuantityOverDimensionedPackage,
				  RowStatus,
				  TokenCreated,
				  DateCreated,
				  SenderId,
				  SenderName,
				  SenderPhone,
				  AmountPickup,
				  IdSourcePlataform,
				  AddressPickup,
				  TypeVehicleId,
				  IsScheduled,
				  SpecialInstructions
			)
  		VALUES
			(
				  @StartDate
				, @EndDate
				, 0
				, 0
				, @quantityRegular
				, NULL
				, 1
				, @token
				, GETDATE()
				, @idSender
				, @nameSender
				, @phoneSender
				, NULL
				, 8					--API Integration
				, @addressPickUp
				, @TypeVehicle
				, 0
				, 'URGENTE Smart Locker'
			);

		SET @idSchedulePickUp = SCOPE_IDENTITY();

		--Validar que tenga registro en la DeliveryOrderPaymentDetail
        SELECT 
			@dopdId = DopId
        FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail WITH(NOLOCK)
        WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber;

		IF @dopdId IS NULL
		BEGIN

			INSERT INTO [dbo].[DeliveryOrderPaymentDetail]
                    (
                        [GuideNumber],
                        [GuideSerie],
                        [PayTypeId],
                        [TypeofInOutMoneyId],
                        [TimePlaId],
                        [amount],
                        [TokenCreated],
                        [DateCreated],
                        [TokenUpdated],
                        [DateUpdated],
                        [PaymentRecollections],
                        [PaymentNow],
                        [PaymentDelivery],
                        [StartDate],
                        [EndDate],
                        [ShipmentCompleted],
                        [RecollectionCompleted],
                        [PaidGuide],
                        [TransaccionFAC],
                        [IdHeaderRecolection],
                        [RecolectNow],
                        [RecolectDelivery],
                        [RecolectPayment]
                    )
                    SELECT 
						@GuideNumber,
                        @GuideSerie,
                        CASE
                            WHEN do.IsCollect = 1 THEN
                            (
                                SELECT PayTypeId FROM DeliveryBackOffice.dbo.CatPaymentType WITH(NOLOCK) WHERE PayTypeAbrev = 'COLLT'
                            )
                            WHEN cu.ConditionOfPaymentID > 1 THEN
                            (
                                SELECT PayTypeId FROM DeliveryBackOffice.dbo.CatPaymentType WITH(NOLOCK) WHERE PayTypeAbrev = 'CREDT'
                            )
                            ELSE
							(
								SELECT PayTypeId FROM DeliveryBackOffice.dbo.CatPaymentType WITH(NOLOCK) WHERE PayTypeAbrev = 'CONT'
							)
                        END,
                        CASE
                            WHEN do.IsCollect = 1				THEN 1
                            WHEN cu.ConditionOfPaymentID > 1	THEN 8
							ELSE 1
                        END,
                        CASE
                            WHEN do.IsCollect = 1 THEN
                            (
                                SELECT TimePlaId FROM DeliveryBackOffice.dbo.CatPaymentTime WITH(NOLOCK) WHERE TimePlaAbrev = 'DEST'
                            )
                            WHEN cu.ConditionOfPaymentID > 1 THEN
                            (
                                SELECT TimePlaId FROM DeliveryBackOffice.dbo.CatPaymentTime WITH(NOLOCK) WHERE TimePlaAbrev = 'POST'
                            )
                            ELSE
							(
								SELECT TimePlaId FROM DeliveryBackOffice.dbo.CatPaymentTime WITH(NOLOCK) WHERE TimePlaAbrev = 'AHR'
							)
                        END,
                        0,
                        @Token,
                        GETDATE(),
                        NULL,
                        NULL,
                        0,
                        0,
                        0,
                        NULL,
                        NULL,
                        0,
                        0,
                        0,
                        NULL,
                        @idSchedulePickUp,
                        NULL,
                        NULL,
                        NULL
					FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.Customer cu WITH(NOLOCK)
						ON cu.IdCustomer =
						(
							SELECT ISNULL(do.IdCustomer, vpc.CustomerID)
							FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
							WHERE vpc.CodeOfReference = do.Sender_ID
						)
                    WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber;
		END
		ELSE
		BEGIN
			UPDATE [dbo].[DeliveryOrderPaymentDetail]
            SET IdHeaderRecolection = @idSchedulePickUp , TokenUpdated = @Token , DateUpdated = GETDATE()
            WHERE DopId = @dopdId;
		END

		IF NOT EXISTS
        ( SELECT 1 FROM [DeliveryBackOffice].[dbo].[ServiceManagement] WITH(NOLOCK) WHERE IdSchedulePickup = @idSchedulePickUp )
        BEGIN
			
			INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement]
            (
                IdSchedulePickup,
                RowStatus,
                TokenCreated,
                DateCreated,
                ServiceStatusId,
                Amount,
                CatPaymentTimeId
            )
            VALUES
            (@idSchedulePickUp, 1, @Token, GETDATE(), 1, @TotalAmount, @CatPaymentTimeId);

            SET @idSchedule = SCOPE_IDENTITY();

            INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
            (
                ServiceManagementId,
                ServiceStatusId,
                RowStauts,
                TokenCreated,
                DateCreated
            )
            VALUES
            (@idSchedule, 1, 1, @Token, GETDATE());

		END
		ELSE
		BEGIN

			DECLARE @LastServiceManagement AS TABLE
            (
                IdServiceManagement INT,
                DateOfSM DATETIME
            );

            UPDATE [dbo].[ServiceManagement]
            SET 
				Amount				= @TotalAmount,
                CatPaymentTimeId	= @CatPaymentTimeId,
                TokenUpdated		= @Token,
                DateUpdated			= GETDATE()
            OUTPUT	inserted.IdServiceManagement,
                    inserted.DateCreated
            INTO @LastServiceManagement
            (
                IdServiceManagement,
                DateOfSM
            )
            WHERE IdSchedulePickup = @idSchedulePickUp;

            SELECT TOP 1 @idSchedule = LSM.IdServiceManagement
            FROM @LastServiceManagement LSM 
            ORDER BY LSM.DateOfSM DESC;

		END;

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