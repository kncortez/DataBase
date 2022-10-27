-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-07>
-- Description:	<Procesa una guía en liquidación de ruta unificada>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_SetUnifiedRouteSettlementDetail]
	-- Add the parameters for the stored procedure here
	@CourierId INT,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@GuidePiece SMALLINT,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--- Variables para manejo de piezas
	DECLARE @GuidePieceExists BIT;
	DECLARE @GuidePieceIsDry BIT;
	DECLARE @CountPiece INT;
	DECLARE @StatusOrder TINYINT;

	--- Variables para control de RouteAssignment
	DECLARE @RouteAssignmentId INT
	DECLARE @RouteAssignmentCourierId INT
	DECLARE @ServiceManagementId INT
	DECLARE @SchedulePickupId BIGINT
	DECLARE @ServiceStatusId INT

	--- Variables para manejo de ruta unificada
	DECLARE @UserSettlement NVARCHAR(50);
	DECLARE @IdUnifiedRouteSettlement INT;
	DECLARE @IdUnifiedRouteSettlementDetail INT;
	DECLARE @IdUnifiedRouteSettlementDetailPiece INT;

	--- Variables para control de tipo de guía
	DECLARE @IsArrival BIT = 0
	DECLARE @IsReturn BIT = 0
	DECLARE @IsDelivered BIT = 0
	DECLARE @IsTransfered BIT = 0
	DECLARE @IsError BIT = 0

	--- Control de procesos abiertos
	DECLARE @IsOpenProcess BIT = 0;
	DECLARE @IsValidOpenProcess BIT = 1;
	DECLARE @UserProcess NVARCHAR(50)

	--- Control de monto de servicio y COD
	DECLARE @IsCollect BIT = 0
	DECLARE @IsLastMileReturn BIT = 0
	DECLARE @ServiceAmount DECIMAL(14,2) = 0
	DECLARE @CODAmount DECIMAL(14,2) = 0

	DECLARE @ServiceStatus INT =
    (
        SELECT IdServiceStatus FROM CatServiceStatus WHERE [Name] = 'Recolectado'
    );

	BEGIN TRANSACTION
	BEGIN TRY

		--- Verificar si la pieza existe
		SELECT
			@GuidePieceExists = 1
			,@GuidePieceIsDry = ISNULL(dop.IsDry, 1)
		FROM DeliveryOrderPiece dop WITH (NOLOCK)
		WHERE dop.GuideSerie = @GuideSerie
		AND dop.GuideNumber = @GuideNumber
		AND dop.NoPiece = @GuidePiece

		IF @GuidePieceExists = 1
		BEGIN

			-- Verificar información de la guía
			SELECT
				@StatusOrder = do.StatusOrderId
			   ,@IsCollect = do.IsCollect
			   ,@ServiceAmount = do.PriceShippment
			   ,@CODAmount = ISNULL(do.Collect_OnDelivery, 0)
			   ,@IsLastMileReturn = ISNULL(do.IsLastMileReturn, 0)
			FROM DeliveryOrder do WITH (NOLOCK)
			WHERE do.Guide_Serie = @GuideSerie
			AND do.Guide_Number = @GuideNumber

			SELECT TOP 1
				@RouteAssignmentId = ra.IdRouteAssigment
			   ,@RouteAssignmentCourierId = ra.IdCurrierMan
			   ,@ServiceManagementId = sm.IdServiceManagement
			   ,@SchedulePickupId = sm.IdSchedulePickup
			   ,@ServiceStatusId = sm.ServiceStatusId
			FROM RouteAssigment ra WITH (NOLOCK)
			INNER JOIN ServiceManagement sm WITH (NOLOCK)
				ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
					AND sm.RowStatus = 1
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON sm.ServiceStatusId = css.IdServiceStatus
			LEFT JOIN ServiceManagementDetail smd WITH (NOLOCK)
				ON sm.IdServiceManagement = smd.ServiceManagement
					AND smd.RowStatus = 1
			LEFT JOIN RoutePreparationDetail rpd WITH (NOLOCK)
				ON smd.IdServiceManagementDetail = rpd.ServiceManagementDetailId
					AND rpd.RowStatus = 1
			LEFT JOIN SchedulePickup sp WITH (NOLOCK)
				ON sm.IdSchedulePickup = sp.SchedulePickupId
					AND sp.RowStatus = 1
					AND (sp.SchedulePickupStatus IS NULL
						OR sp.SchedulePickupStatus = 1)
			LEFT JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
				ON sp.SchedulePickupId = dopd.IdHeaderRecolection
			WHERE css.[Name] <> 'Cancelado'
			AND ra.DateOfRoute = CAST(GETDATE() AS DATE)
			AND ISNULL(dopd.GuideSerie, rpd.Guide_Serie) = @GuideSerie
			AND ISNULL(dopd.GuideNumber, rpd.Guide_Number) = @GuideNumber
			ORDER BY ra.DateCreated DESC 

			-- Verificar si es un proceso abierto, de ser así debe continuar el usuario que lo abrió
			SET @CountPiece = (SELECT
					COUNT(1)
				FROM DeliveryOrderPiece WITH (NOLOCK)
				WHERE GuideSerie = @GuideSerie
				AND GuideNumber = @GuideNumber)

			--- Si tiene más de una pieza es un proceso abierto
			IF @CountPiece > 1
				SET @IsOpenProcess = 1

			-- si no está asignada a una ruta o sino pertenece al courier
			IF ((@RouteAssignmentId IS NULL
				AND @StatusOrder IN (SELECT
						so.StatusOrderId
					FROM StatusOrder so
					WHERE so.OrderDescription IN ('Generado', 'Solicitado'))
				)
				OR (@RouteAssignmentCourierId <> @CourierId
				AND @ServiceStatusId IN (SELECT
						css.IdServiceStatus
					FROM CatServiceStatus css
					WHERE css.[Name] IN ('Creado', 'Asignado a Ruta'))
				)
				)
			BEGIN

				-- Buscar una ruta
				SET @RouteAssignmentId = (SELECT TOP 1
						ra.IdRouteAssigment
					FROM RouteAssigment ra WITH (NOLOCK)
					INNER JOIN CatRoute cr WITH (NOLOCK)
						ON ra.IdRoute = cr.IdRoute
					INNER JOIN CatTypeRoute ctr WITH (NOLOCK)
						ON cr.IdTypeRoute = ctr.IdTypeRoute
					WHERE ra.IdCurrierMan = @CourierId
					AND ra.DateOfRoute = CAST(GETDATE() AS DATE)
					AND ctr.[Name] = 'Recolección'
					AND ra.RowStatus = 1
					ORDER BY ra.DateCreated DESC)

				IF @RouteAssignmentId IS NOT NULL
				BEGIN
					IF (@StatusOrder IN (SELECT
								so.StatusOrderId
							FROM StatusOrder so WITH(NOLOCK)
							WHERE so.OrderDescription IN ('Generado', 'Solicitado'))
						)
					BEGIN
						-- Si no generará un proceso abierto, proceder a actualizar estados
						IF NOT @IsOpenProcess = 1
						BEGIN
							DECLARE @StatusOrderId TINYINT = (SELECT
									so.StatusOrderId
								FROM StatusOrder so WITH (NOLOCK)
								WHERE so.OrderDescription = 'Recolectado')

							--Actualiza estado de la guía
							UPDATE DeliveryOrder
							SET StatusOrderId = @StatusOrderId
							WHERE Guide_Serie = @GuideSerie
							AND Guide_Number = @GuideNumber

							--Inserta checkpoint de recolectado
							INSERT INTO DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius, PieceId, RowStatus)
								VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @Token, GETDATE(), GETDATE(), NULL, NULL, NULL, 1);
						END
					END 

					--Validar si pertenece a un punto de visita
					DECLARE @tiempo DATE = (SELECT
							CAST(GETDATE() AS DATE));
					DECLARE @Sender_ID INT;
					DECLARE @dopdId BIGINT;
					DECLARE @ServiceManagementIdFind INT;
					DECLARE @SchedulePickupIdFind BIGINT;
					DECLARE @RouteAssigmentFind INT;
					DECLARE @FindServiceManagement BIT = 0;
					DECLARE @CreateServiceManagement BIT = 0;

					DECLARE @VehicleTypeId INT = (SELECT
							cv.IdTypeVehicle
						FROM RouteAssigment ra
						INNER JOIN CatVehicle cv
							ON cv.IdVehicle = ra.IdVehicle
						WHERE ra.IdRouteAssigment = @RouteAssignmentId);


					--Validar que tenga registro en la DeliveryOrderPaymentDetail sino lo crea
					SELECT
						@dopdId = dopd.DopId
					   ,@SchedulePickupId = dopd.IdHeaderRecolection
					FROM DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
					WHERE dopd.GuideSerie = @GuideSerie
					AND dopd.GuideNumber = @GuideNumber;

					IF @dopdId IS NULL
					BEGIN
						INSERT INTO [dbo].[DeliveryOrderPaymentDetail] ([GuideNumber],
						[GuideSerie],
						[PayTypeId],
						[TypeofInOutMoneyId],
						[TimePlaId],
						[Amount],
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
						[RecolectPayment])
							SELECT
								@GuideNumber
							   ,@GuideSerie
							   ,CASE
									WHEN do.IsCollect = 1 THEN (SELECT
												PayTypeId
											FROM CatPaymentType WITH (NOLOCK)
											WHERE PayTypeAbrev = 'COLLT')
									WHEN cu.ConditionOfPaymentID > 1 THEN (SELECT
												PayTypeId
											FROM CatPaymentType WITH (NOLOCK)
											WHERE PayTypeAbrev = 'CREDT')
									ELSE (SELECT
												PayTypeId
											FROM CatPaymentType WITH (NOLOCK)
											WHERE PayTypeAbrev = 'CONT')
								END
							   ,CASE
									WHEN do.IsCollect = 1 THEN 1
									WHEN cu.ConditionOfPaymentID > 1 THEN 8
									ELSE 1
								END
							   ,CASE
									WHEN do.IsCollect = 1 THEN (SELECT
												TimePlaId
											FROM CatPaymentTime WITH (NOLOCK)
											WHERE TimePlaAbrev = 'DEST')
									WHEN cu.ConditionOfPaymentID > 1 THEN (SELECT
												TimePlaId
											FROM CatPaymentTime WITH (NOLOCK)
											WHERE TimePlaAbrev = 'POST')
									ELSE (SELECT
												TimePlaId
											FROM CatPaymentTime WITH (NOLOCK)
											WHERE TimePlaAbrev = 'AHR')
								END
							   ,0
							   ,@Token
							   ,GETDATE()
							   ,NULL
							   ,NULL
							   ,0
							   ,0
							   ,0
							   ,NULL
							   ,NULL
							   ,0
							   ,0
							   ,0
							   ,NULL
							   ,NULL
							   ,NULL
							   ,NULL
							   ,NULL
							FROM DeliveryOrder do WITH (NOLOCK)
							LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
								ON do.Sender_ID = vpc.CodeOfReference
							INNER JOIN Customer cu WITH (NOLOCK)
								ON ISNULL(do.IdCustomer, vpc.CustomerID) = cu.IdCustomer
							WHERE do.Guide_Serie = @GuideSerie
							AND do.Guide_Number = @GuideNumber;

						SET @dopdId = SCOPE_IDENTITY();
					END

					--Validar si pertenece a un punto de visita para buscar si ya existe el servicio
					SELECT @Sender_ID = do.Sender_ID
					FROM DeliveryOrder do WITH (NOLOCK)
					WHERE do.Guide_Serie = @GuideSerie
							AND do.Guide_Number = @GuideNumber;

					--Si tiene un SchedulePickup buscar si ya está asignado a un servicio y si es el correcto
					IF @SchedulePickupId IS NOT NULL
					BEGIN

						UPDATE SchedulePickup
						SET AssigmentStatus = 1,
							TokenUpdated = @Token,
							DateUpdated = GETDATE()
						WHERE SchedulePickupId = @SchedulePickupId;

						--Buscar si tiene asignado un servicio
						SELECT @ServiceManagementId = sm.IdServiceManagement
						FROM ServiceManagement sm WITH (NOLOCK)
						WHERE sm.IdSchedulePickup = @SchedulePickupId;

						--Si encontró el servicio
						IF @ServiceManagementId IS NOT NULL
						BEGIN

							--Válidar que este asignado a la ruta
							IF EXISTS
							(
								SELECT 1
								FROM RouteAssigment ra WITH (NOLOCK)
									INNER JOIN ServiceManagement sm WITH(NOLOCK)
										ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
										   AND sm.IdServiceManagement = @ServiceManagementId
								WHERE ra.IdRouteAssigment = @RouteAssignmentId
							)
							BEGIN

								IF NOT @IsOpenProcess = 1
								BEGIN
									--Se marca como recolectado
									UPDATE sm
									SET ServiceStatusId = @ServiceStatus,
										TokenUpdated = @Token,
										DateUpdated = GETDATE()
									FROM ServiceManagement sm
									WHERE sm.IdServiceManagement = @ServiceManagementId;

									--Insertar EventService si no existe
									IF NOT EXISTS
									(
										SELECT 1
										FROM EventService es
										WHERE es.ServiceManagementId = @ServiceManagementId
											  AND es.ServiceStatusId = @ServiceStatus
											  AND es.RowStauts = 1
									)
									BEGIN
										INSERT INTO EventService
										(
											ServiceManagementId,
											ServiceStatusId,
											RowStauts,
											TokenCreated,
											DateCreated,
											Observations
										)
										VALUES
										(@ServiceManagementId, @ServiceStatus, 1, @Token, GETDATE(), NULL);
									END;
								END
							END
							ELSE
							BEGIN
								SET @FindServiceManagement = 1;
							END
						END
						ELSE
						BEGIN
							SET @FindServiceManagement = 1;
						END
					END
					ELSE
					BEGIN
						SET @FindServiceManagement = 1;
					END

					--Si se tiene que buscar si un servicio si coincide con el vp
					IF @FindServiceManagement = 1
					BEGIN

						IF @Sender_ID IS NOT NULL
							AND @Sender_ID <> 0
						BEGIN
							SELECT
								@SchedulePickupIdFind = sm.IdSchedulePickup
							   ,@ServiceManagementIdFind = sm.IdServiceManagement
							FROM RouteAssigment ra WITH (NOLOCK)
							INNER JOIN ServiceManagement sm WITH (NOLOCK)
								ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
							INNER JOIN SchedulePickup sp WITH (NOLOCK)
								ON sp.SchedulePickupId = sm.IdSchedulePickup
							WHERE ra.IdRouteAssigment = @RouteAssignmentId
							AND sp.SenderId = @Sender_ID;
						END;
						ELSE
						BEGIN
							--Buscar por Dirección
							SELECT
								@SchedulePickupIdFind = sm.IdSchedulePickup
							   ,@ServiceManagementIdFind = sm.IdServiceManagement
							FROM RouteAssigment ra WITH (NOLOCK)
							INNER JOIN ServiceManagement sm WITH (NOLOCK)
								ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
							INNER JOIN SchedulePickup sp WITH (NOLOCK)
								ON sp.SchedulePickupId = sm.IdSchedulePickup
							INNER JOIN DeliveryOrder do WITH (NOLOCK)
								ON do.Guide_Serie = @GuideSerie
									AND do.Guide_Number = @GuideNumber
									AND sp.AddressPickup = do.Sender_Address
							WHERE ra.IdRouteAssigment = @RouteAssignmentId
							AND sp.AddressPickup = do.Sender_Address;
						END;

						--Si se encuentra el vp entre los servicios de recolección, se asigna
						IF @SchedulePickupIdFind IS NOT NULL
						BEGIN
							SET @ServiceManagementId = @ServiceManagementIdFind
							SET @SchedulePickupId = @SchedulePickupIdFind

							UPDATE DeliveryOrderPaymentDetail
							SET IdHeaderRecolection = @SchedulePickupIdFind
							   ,TokenUpdated = @Token
							   ,DateUpdated = GETDATE()
							WHERE GuideSerie = @GuideSerie
							AND GuideNumber = @GuideNumber;

							IF NOT @IsOpenProcess = 1
							BEGIN

								--Se marca como recolectado
								UPDATE sm
								SET ServiceStatusId = @ServiceStatusId,
									TokenUpdated = @Token,
									DateUpdated = GETDATE()
								FROM ServiceManagement sm
								WHERE sm.IdSchedulePickup = @SchedulePickupIdFind;


								UPDATE SchedulePickup
								SET AssigmentStatus = 1
								   ,TokenUpdated = @Token
								   ,DateUpdated = GETDATE()
								WHERE SchedulePickupId = @SchedulePickupIdFind;

								--Insertar EventService si no existe
								IF NOT EXISTS
								(
									SELECT 1
									FROM EventService es
									WHERE es.ServiceManagementId = @ServiceManagementIdFind
										  AND es.ServiceStatusId = @ServiceStatus
										  AND es.RowStauts = 1
								)
								BEGIN
									INSERT INTO EventService
									(
										ServiceManagementId,
										ServiceStatusId,
										RowStauts,
										TokenCreated,
										DateCreated,
										Observations
									)
									VALUES
									(@ServiceManagementIdFind, @ServiceStatus, 1, @Token, GETDATE(), NULL);
								END
							END
						END
						ELSE
						BEGIN
							SET @CreateServiceManagement = 1;
						END
					END


					--Si se tiene que crear el servicio
					IF @CreateServiceManagement = 1
					BEGIN
						-- Si no tiene un SchedulePicku, lo crea y lo asigna
						IF @SchedulePickupId IS NULL
						BEGIN

							INSERT INTO [dbo].[SchedulePickup] ([AccountId],
							[StartDate],
							[EndDate],
							[EstimatedWeight],
							[IsLargePackage],
							[QuantityRegularPackages],
							[QuantityOverDimensionedPackage],
							[SpecialInstructions],
							[RowStatus],
							[TokenCreated],
							[DateCreated],
							[TokenUpdated],
							[DateUpdated],
							[SenderId],
							[SenderName],
							[SenderPhone],
							[IdHubLogistics],
							[AmountPickup],
							[IdSourcePlataform],
							[AddressPickup],
							[AssigmentStatus],
							[TransaccionFAC],
							[TownshipId],
							[SchedulePickupStatus],
							[TypeVehicleId],
							[IsScheduled])
								SELECT TOP 1
									acc.AccIdAccount
								   ,CONCAT(CAST(GETDATE() AS DATE), ' 08:00:00')
								   ,CONCAT(CAST(GETDATE() AS DATE), ' 17:00:00')
								   ,0
								   ,0
								   ,0
								   ,0
								   ,''
								   ,1
								   ,@Token
								   ,GETDATE()
								   ,NULL
								   ,NULL
								   ,do.Sender_ID
								   ,CONCAT(
									ISNULL(do.Sender_FirstName, ''),
									IIF(do.Sender_FirstName IS NULL, '', IIF(do.Sender_LastName IS NULL, '', ' ')),
									ISNULL(do.Sender_LastName, '')
									)
								   ,do.Sender_Phone
								   ,NULL -- [IdHubLogistics]
								   ,NULL -- [AmountPickup]
								   ,2 -- [IdSourcePlataform]
								   ,do.Sender_Address
								   ,1
								   ,NULL --TransaccionFAC
								   ,ISNULL(do.SenderIdTownship, ( SELECT TOP 1
										   t.IdTownship
									   FROM Township t WITH (NOLOCK)
									   WHERE t.TownshipName = do.Sender_Town AND t.TownshipStatus = 1)) --TownshipId
								   ,1
								   ,@VehicleTypeId
								   ,0
								FROM DeliveryOrder do WITH (NOLOCK)
								LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
									ON do.Sender_ID = vpc.CodeOfReference
								LEFT JOIN Account acc
									ON ISNULL(do.IdCustomer, vpc.CustomerID) = acc.IdCustomer
								WHERE do.Guide_Serie = @GuideSerie
								AND do.Guide_Number = @GuideNumber

							SET @SchedulePickupId = SCOPE_IDENTITY()

							UPDATE DeliveryOrderPaymentDetail
							SET IdHeaderRecolection = @SchedulePickupId
							   ,TokenUpdated = @Token
							   ,DateUpdated = GETDATE()
							WHERE DopId = @dopdId
						END
						ELSE
						BEGIN
							UPDATE SchedulePickup
							SET AssigmentStatus = 1
							   ,TypeVehicleId = @VehicleTypeId
							   ,TokenUpdated = @Token
							   ,DateUpdated = GETDATE()
							WHERE SchedulePickupId = @SchedulePickupId
						END

						
						--Crea el servicio y lo asigna
						INSERT INTO [dbo].[ServiceManagement] ([IdPuCourrier],
						[IdDlCourrier],
						[CiPuDate],
						[CoPuDate],
						[CiDlDate],
						[CoDlDate],
						[IdPuRouteAssigment],
						[IdDlRouteAssigment],
						[IdSchedulePickup],
						[IdProofOnDelivery],
						[RowStatus],
						[TokenCreated],
						[DateCreated],
						[TokenUpdated],
						[DateUpdated],
						[ServiceStatusId],
						[PuSignaturePath],
						[DiSignaturePath],
						[SubTypeServiceManagmentId],
						[IdHubDestination],
						[Order])
							SELECT
								ra.IdCurrierMan
							   ,NULL
							   ,NULL
							   ,NULL
							   ,NULL
							   ,NULL
							   ,ra.IdRouteAssigment
							   ,NULL
							   ,@SchedulePickupId
							   ,NULL
							   ,1
							   ,@Token
							   ,GETDATE()
							   ,NULL
							   ,NULL
							   ,3
							   ,NULL
							   ,NULL
							   ,1
							   ,NULL
							   ,1
							FROM RouteAssigment ra WITH (NOLOCK)
							WHERE ra.IdRouteAssigment = @RouteAssignmentId

						SET @ServiceManagementId = SCOPE_IDENTITY()

						IF NOT @IsOpenProcess = 1
						BEGIN
							--Insertar EventService si no existe
							IF NOT EXISTS
							(
								SELECT 1
								FROM EventService es
								WHERE es.ServiceManagementId = @ServiceManagementId
										AND es.ServiceStatusId = @ServiceStatus
										AND es.RowStauts = 1
							)
							BEGIN
								INSERT INTO EventService
								(
									ServiceManagementId,
									ServiceStatusId,
									RowStauts,
									TokenCreated,
									DateCreated,
									Observations
								)
								VALUES
								(@ServiceManagementId, @ServiceStatus, 1, @Token, GETDATE(), NULL);
							END
						END
					END
				END
			END 

			IF @RouteAssignmentId IS NOT NULL AND @ServiceManagementId IS NOT NULL
			BEGIN

				--- Verificar si existe la ruta unificada y si ya fue liquidada
				SELECT
					@IdUnifiedRouteSettlement = urs.IdUnifiedRouteSettlement
				   ,@UserSettlement = urs.UserSettlement
				FROM UnifiedRouteSettlement urs WITH (NOLOCK)
				WHERE urs.RouteAssignmentId = @RouteAssignmentId
				AND urs.RowStatus = 1

				IF @IdUnifiedRouteSettlement IS NULL 
				BEGIN

					--- No existe la ruta unificada debe ser generado
					INSERT INTO UnifiedRouteSettlement (RouteAssignmentId, TotalGuidesSettled, TotalPiecesSettled, TotalPiecesMissing, UserSettlement, DateSettlement, SettlementStation, TotalCODGuidesSettled, UserCODSettlement, DateCODSettlement, CODSettlementStation, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
						VALUES (@RouteAssignmentId, DEFAULT, DEFAULT, DEFAULT, NULL, NULL, NULL, DEFAULT, NULL, NULL, NULL, DEFAULT, @Token, GETDATE(), NULL, NULL);

					SET @IdUnifiedRouteSettlement = SCOPE_IDENTITY()
				END
				
				IF @IdUnifiedRouteSettlement IS NOT NULL
				BEGIN

					--- Validar que la ruta no haya sido liquidada

					IF @UserSettlement IS NULL
					BEGIN
						
						
						-- Verificar si existe la guía en el detalle de la preparación de ruta
						SELECT
							@IdUnifiedRouteSettlementDetail = ursd.IdUnifiedRouteSettlementDetail
						FROM UnifiedRouteSettlementDetail ursd
						WHERE ursd.UnifiedRouteSettlementId = @IdUnifiedRouteSettlement
						AND ursd.GuideSerie = @GuideSerie
						AND ursd.GuideNumber = @GuideNumber
						AND (ursd.RowStatus = 1 OR ursd.IsOpenProcess = 1) 

						IF @IdUnifiedRouteSettlementDetail IS NULL
						BEGIN
							
							-- Verificar a qué flujo pertenece la guía
							SELECT
								@IsArrival = IIF(Flow.GuideFlow = 'IsArrival', 1, 0)
							   ,@IsReturn = IIF(Flow.GuideFlow = 'IsReturn', 1, 0)
							   ,@IsDelivered = IIF(Flow.GuideFlow = 'IsDelivered', 1, 0)
							   ,@IsTransfered = IIF(Flow.GuideFlow = 'IsTransfered', 1, 0)
							   ,@IsError = IIF(Flow.GuideFlow = 'IsError', 1, 0)
							FROM (SELECT
									(CASE
										WHEN smd.IdServiceManagementDetail IS NOT NULL THEN CASE
												WHEN so.OrderDescription IN ('Entregado', 'COD liquidado', 'COD pagado', 'Devuelto') THEN 'IsDelivered'
												WHEN so.OrderDescription IN ('Traslado a Express Center', 'Entregado En Express Center', 'Devuelto en Express Center') THEN 'IsTransfered'
												WHEN (do.IsLastMileReturn IS NULL OR
													do.IsLastMileReturn = 0) THEN CASE
														WHEN ISNULL((SELECT
																	rh.Attempt
																FROM RateHeader rh WITH (NOLOCK)
																LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
																	ON vpc.CodeOfReference = do.Sender_ID
																INNER JOIN RatebyCustomer rc WITH (NOLOCK)
																	ON rc.RbcIdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
																WHERE rh.RheId = rc.RbcIdRate)
															, 2) > (SELECT
																	COUNT(1)
																FROM DeliveryOrderDetail dod WITH (NOLOCK)
																INNER JOIN StatusOrder so WITH (NOLOCK)
																	ON so.StatusOrderId = dod.StatusOrderId
																WHERE dod.RowStatus = 1
																AND dod.Guide_Serie = do.Guide_Serie
																AND dod.Guide_Number = do.Guide_Number
																AND so.OrderDescription = 'Intento de entrega fallida') THEN 'IsArrival'
														ELSE 'IsReturn'
													END
												ELSE CASE
														WHEN (SELECT
																	ISNULL(rh.Attempt, 2) + rh.AttemptReturn
																FROM RateHeader rh WITH (NOLOCK)
																LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
																	ON vpc.CodeOfReference = do.Sender_ID
																INNER JOIN RatebyCustomer rc WITH (NOLOCK)
																	ON rc.RbcIdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
																WHERE rh.RheId = rc.RbcIdRate)
															> (SELECT
																	COUNT(1)
																FROM DeliveryOrderDetail dod WITH (NOLOCK)
																INNER JOIN StatusOrder so WITH (NOLOCK)
																	ON so.StatusOrderId = dod.StatusOrderId
																WHERE dod.RowStatus = 1
																AND dod.Guide_Serie = do.Guide_Serie
																AND dod.Guide_Number = do.Guide_Number
																AND so.OrderDescription = 'Intento de entrega fallida') THEN 'IsReturn'
														ELSE 'IsBazar'
													END
											END
										WHEN sm.IdSchedulePickup IS NOT NULL AND
											so.OrderDescription NOT IN ('Anulado') THEN 'IsArrival'
										ELSE 'IsError'
									END) GuideFlow
								FROM DeliveryOrder do WITH (NOLOCK)
								INNER JOIN StatusOrder so (NOLOCK)
									ON do.StatusOrderId = so.StatusOrderId
								INNER JOIN ServiceManagement sm WITH (NOLOCK)
									ON sm.IdServiceManagement = @ServiceManagementId
								LEFT JOIN ServiceManagementDetail smd WITH (NOLOCK)
									ON sm.IdServiceManagement = smd.ServiceManagement
								WHERE do.Guide_Serie = @GuideSerie
								AND do.Guide_Number = @GuideNumber) Flow
							

							INSERT INTO UnifiedRouteSettlementDetail (UnifiedRouteSettlementId, ServiceManagementId, GuideSerie, GuideNumber, ServiceSettlementAmount, ServiceCODSettlementAmount, IsArrival, IsReturn, IsDelivered, IsTransfered, RowStatus, TokenCreated, DateCreated)
								VALUES (@IdUnifiedRouteSettlement, @ServiceManagementId, @GuideSerie, @GuideNumber, CASE WHEN @IsDelivered = 1 THEN IIF(@IsCollect = 1, @ServiceAmount, 0) ELSE 0 END, CASE WHEN @IsDelivered = 1 AND @IsLastMileReturn = 0 THEN @CODAmount ELSE 0 END, @IsArrival, @IsReturn, @IsDelivered, @IsTransfered, 1, @Token, GETDATE());
							
							SET @IdUnifiedRouteSettlementDetail = SCOPE_IDENTITY()

							--- Actualizar contadores de guías si no es un proceso abierto 
							IF @IsOpenProcess <> 1
								UPDATE UnifiedRouteSettlement
								SET TotalGuidesSettled += 1
								WHERE IdUnifiedRouteSettlement = @IdUnifiedRouteSettlement
						END

						IF @IsError <> 1
						BEGIN 

							IF @IdUnifiedRouteSettlementDetail IS NOT NULL
							BEGIN

								--- Verificar si existe la pieza de la guía dentro del detalle de la ruta unificada
								SELECT 
									@IdUnifiedRouteSettlementDetailPiece = ursdp.IdUnifiedRouteSettlementDetailPiece
								FROM UnifiedRouteSettlementDetailPiece ursdp
								INNER JOIN UnifiedRouteSettlementDetail ursd
									ON ursdp.UnifiedRouteSettlementDetailId = ursd.IdUnifiedRouteSettlementDetail
								WHERE ursdp.UnifiedRouteSettlementDetailId = @IdUnifiedRouteSettlementDetail
								AND ursdp.PieceNumber = @GuidePiece
								AND (ursdp.RowStatus = 1 OR (ursd.IsOpenProcess = 1 AND ursd.UserProcess IS NOT NULL))

								IF @IdUnifiedRouteSettlementDetailPiece IS NULL 
								BEGIN 

									INSERT INTO UnifiedRouteSettlementDetailPiece (UnifiedRouteSettlementDetailId, PieceNumber, IsDryPiece, RowStatus, TokenCreated, DateCreated)
										VALUES (@IdUnifiedRouteSettlementDetail, @GuidePiece, @GuidePieceIsDry, 1, @Token, GETDATE());

									SET @IdUnifiedRouteSettlementDetailPiece = SCOPE_IDENTITY()

									--- Actualizar contadores de piezas si no es un proceso abierto
									IF @IsOpenProcess <> 1
									BEGIN 
										UPDATE UnifiedRouteSettlement
										SET TotalPiecesSettled += 1
										WHERE IdUnifiedRouteSettlement = @IdUnifiedRouteSettlement

										UPDATE UnifiedRouteSettlementDetail
										SET PiecesSettled += 1
										WHERE IdUnifiedRouteSettlementDetail = @IdUnifiedRouteSettlementDetail
									END
								END

								--- Si es un proceso abierto
								IF (@IsOpenProcess = 1)
								BEGIN

									IF EXISTS (SELECT
											1
										FROM UnifiedRouteSettlementDetail ursd
										WHERE ursd.IdUnifiedRouteSettlementDetail = @IdUnifiedRouteSettlementDetail
										AND (ursd.UserProcess = @Token
										OR ursd.UserProcess IS NULL))
									BEGIN
										UPDATE UnifiedRouteSettlementDetail
										SET IsOpenProcess = 1
										   ,UserProcess = @Token
										   ,RowStatus = 0
										WHERE IdUnifiedRouteSettlementDetail = @IdUnifiedRouteSettlementDetail

										UPDATE UnifiedRouteSettlementDetailPiece
										SET RowStatus = 0
										WHERE IdUnifiedRouteSettlementDetailPiece = @IdUnifiedRouteSettlementDetailPiece
									END
									ELSE 
									BEGIN
										SET @IsValidOpenProcess = 0;

										SELECT
											@UserProcess = ursd.UserProcess
										FROM UnifiedRouteSettlementDetail ursd
										WHERE ursd.IdUnifiedRouteSettlementDetail = @IdUnifiedRouteSettlementDetail
									END
								END

								IF @IdUnifiedRouteSettlementDetailPiece IS NOT NULL AND @IsValidOpenProcess = 1
								BEGIN
									COMMIT TRANSACTION

									SELECT
										1 'StatusCode'
									   ,'Pieza asignada correctamente.' 'Description'
									   ,@IsOpenProcess 'IsOpenProcess'
									   ,(CASE
											WHEN @SchedulePickupId IS NOT NULL THEN 'Recolección'
											WHEN @IsLastMileReturn = 1 THEN 'Devolución'
											ELSE 'Entrega'
										END) 'FlowType'

									SELECT
										dop.NoPiece
									   ,dop.IsDry
									FROM DeliveryOrderPiece dop WITH (NOLOCK)
									WHERE dop.GuideSerie = @GuideSerie
									AND dop.GuideNumber = @GuideNumber

								END
								ELSE
								BEGIN
									ROLLBACK TRANSACTION

									IF @IsValidOpenProcess = 1
										SELECT
											8 'StatusCode'
										   ,'Ocurrió un error asignar pieza en la ruta unificada.' 'Description'
									ELSE
										SELECT
											9 'StatusCode'
										   ,'Ya existe un proceso abierto para la guía con otro usuario.' 'Description'
										   ,ISNULL((SELECT
													CONCAT(p.PerFirstName, ' ', p.PerLastName)
												FROM TokenLog tl WITH (NOLOCK)
												INNER JOIN RegisterUser ru WITH (NOLOCK)
													ON ru.UsrIdUser = tl.TknIdUser
												INNER JOIN Person p WITH (NOLOCK)
													ON p.PerIdPerson = ru.UsrIdPerson
												WHERE tl.TknIdToken = @UserProcess)
											, ISNULL((SELECT
													CONCAT(llbt.SSN_IdUser, ' - ', llbt.SSN_Username)
												FROM DenariusUser_Dev.dbo.LGN_LogByToken llbt WITH (NOLOCK)
												WHERE llbt.SSN_IdToken = @UserProcess)
											, 'N/A')) 'UserProcess'	
								END
							END
							ELSE
							BEGIN
								ROLLBACK TRANSACTION

								SELECT
									7 'StatusCode'
								   ,'Ocurrió un error al crear el detalle de la ruta unificada.' 'Description'
							END
						END
						ELSE
						BEGIN
							ROLLBACK TRANSACTION

							SELECT
								6 'StatusCode'
							   ,'La guía no se encuentra en un flujo válido, por favor verifique el estado de la guía.' 'Description'
						END
					END
					ELSE
					BEGIN
						ROLLBACK TRANSACTION

						SELECT
							5 'StatusCode'
						   ,'La ruta ya ha sido liquidada.' 'Description'
					END
				END
				ELSE
				BEGIN
					ROLLBACK TRANSACTION

					SELECT
						4 'StatusCode'
					   ,'Ocurrió un error al crear la ruta unificada.' 'Description'
				END
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION

				SELECT
					3 'StatusCode'
				   ,CONCAT('La guía ', @GuideSerie, @GuideNumber, ' no puede ser asignada, pertenece a otro Courier y ya fué operada o el courier no tiene ruta asignada.') 'Description'
			END
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION

			SELECT
				2 'StatusCode'
			   ,CONCAT('La pieza ', @GuideSerie, @GuideNumber, '-',@GuidePiece, ' no existe.') 'Description'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH


END