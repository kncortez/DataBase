-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-06-03>
-- Description:	<Realiza la liquidación de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_SetSpecialRouteSettlement]
	-- Add the parameters for the stored procedure here
	@CatRouteId INT,
	@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @TSERoutePreparationHeaderId INT = 0
	DECLARE @CourierId INT
	DECLARE @CatVehicleId INT
	DECLARE @RouteAssignmentId INT = 0

	BEGIN TRANSACTION
	BEGIN TRY

		SELECT
			@TSERoutePreparationHeaderId = trph.IDTSERoutePreparationHeader
		   ,@CourierId = trph.SenderReceiverId
		   ,@CatVehicleId = trph.IdCatVehicle
		FROM TSERoutePreparationHeader trph WITH (NOLOCK)
		WHERE trph.IdCatRoute = @CatRouteId
		AND trph.RowStatus = 1
		AND trph.HasFirstPickupProcess = 1
		AND trph.HasFirstArrivalProcess = 1
		AND trph.HasFirstDispatchProcess = 1
		AND trph.HasFirstDeliveryProccess = 0

		IF @TSERoutePreparationHeaderId > 0
		BEGIN

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

			IF @RouteAssignmentId IS NULL OR @RouteAssignmentId = 0
			BEGIN 
				INSERT INTO [DeliveryBackOffice].[dbo].[RouteAssigment] (IdRoute, IdCurrierMan, IdVehicle, DateOfRoute, RowStatus, TokenCreated, DateCreated)
					VALUES (@CatRouteId, @CourierId, @CatVehicleId, CAST(GETDATE() AS DATE), 1, @Token, GETDATE())	

				SET @RouteAssignmentId = SCOPE_IDENTITY()
			END

			DECLARE @GuidesIterate TABLE (
				GuideSerie NVARCHAR(2)
				,GuideNumber INT
			);

			INSERT INTO @GuidesIterate
				SELECT
					do.Guide_Serie
					,do.Guide_Number
				FROM DeliveryOrder do WITH (NOLOCK)
				INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
					ON do.Guide_Serie = trpd.GuideSerie
						AND do.Guide_Number = trpd.GuideNumber
				WHERE trpd.TSERoutePreparationHeaderID = @TSERoutePreparationHeaderId
				AND trpd.RowStatus = 1
				AND (do.Pieces_Dry + do.Pieces_Cold) > 1

			DECLARE @GuideSerie NVARCHAR(2)
			DECLARE @GuideNumber INT
			DECLARE @SchedulePickupId BIGINT
			DECLARE @dopdId BIGINT
			DECLARE @ServiceManagementId INT
			DECLARE @ServiceStatus INT =
			(
				SELECT IdServiceStatus FROM CatServiceStatus WHERE [Name] = 'Asignado a Ruta'
			);

			DECLARE @VehicleTypeId INT = (SELECT
						cv.IdTypeVehicle
					FROM RouteAssigment ra WITH (NOLOCK)
					INNER JOIN CatVehicle cv WITH (NOLOCK)
						ON cv.IdVehicle = ra.IdVehicle
					WHERE ra.IdRouteAssigment = @RouteAssignmentId);

			WHILE EXISTS (SELECT
				TOP 1
					1
				FROM @GuidesIterate)
			BEGIN
				SELECT TOP 1
					@GuideSerie = GuideSerie
					,@GuideNumber = GuideNumber
				FROM @GuidesIterate

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
						,CAST(CONCAT(CAST(GETDATE() AS DATE), ' 08:00:00') AS DATETIME)
						,CAST(CONCAT(CAST(GETDATE() AS DATE), ' 17:00:00') AS DATETIME)
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
						ISNULL(do.Receiver_FirstName, ''),
						IIF(do.Receiver_FirstName IS NULL, '', IIF(do.Receiver_LastName IS NULL, '', ' ')),
						ISNULL(do.Receiver_LastName, '')
						)
						,do.Receiver_Phone
						,NULL -- [IdHubLogistics]
						,NULL -- [AmountPickup]
						,2 -- [IdSourcePlataform]
						,do.Receiver_Address
						,1
						,NULL --TransaccionFAC
						,ISNULL(do.ReceiverIdTownship, (SELECT TOP 1
								t.IdTownship
							FROM Township t WITH (NOLOCK)
							WHERE t.TownshipName = do.Receiver_Town
							AND t.TownshipStatus = 1)
						) --TownshipId
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


				SELECT
					@dopdId = dopd.DopId
				FROM DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
				WHERE dopd.GuideSerie = @GuideSerie
				AND dopd.GuideNumber = @GuideNumber

				IF @dopdId IS NULL
				BEGIN

					INSERT INTO [dbo].[DeliveryOrderPaymentDetail] ([GuideNumber]
					, [GuideSerie]
					, [PayTypeId]
					, [TypeofInOutMoneyId]
					, [TimePlaId]
					, [amount]
					, [TokenCreated]
					, [DateCreated]
					, [TokenUpdated]
					, [DateUpdated]
					, [PaymentRecollections]
					, [PaymentNow]
					, [PaymentDelivery]
					, [StartDate]
					, [EndDate]
					, [ShipmentCompleted]
					, [RecollectionCompleted]
					, [PaidGuide]
					, [TransaccionFAC]
					, [IdHeaderRecolection]
					, [RecolectNow]
					, [RecolectDelivery]
					, [RecolectPayment])
						SELECT
							@GuideNumber
							,@GuideSerie
							,CASE
								WHEN do.IsCollect = 1 THEN (SELECT
											PayTypeId
										FROM CatPaymentType
										WHERE PayTypeAbrev = 'COLLT')
								WHEN cu.ConditionOfPaymentID > 1 THEN (SELECT
											PayTypeId
										FROM CatPaymentType
										WHERE PayTypeAbrev = 'CREDT')
								ELSE (SELECT
											PayTypeId
										FROM CatPaymentType
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
										FROM CatPaymentTime
										WHERE TimePlaAbrev = 'DEST')
								WHEN cu.ConditionOfPaymentID > 1 THEN (SELECT
											TimePlaId
										FROM CatPaymentTime
										WHERE TimePlaAbrev = 'POST')
								ELSE (SELECT
											TimePlaId
										FROM CatPaymentTime
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
							,@SchedulePickupId
							,NULL
							,NULL
							,NULL
						FROM DeliveryOrder do WITH (NOLOCK)
						LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
							ON vpc.CodeOfReference = do.Sender_ID
						INNER JOIN Customer cu WITH (NOLOCK)
							ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
						WHERE do.Guide_Serie = @GuideSerie
						AND do.Guide_Number = @GuideNumber

					END
					ELSE
					UPDATE [dbo].[DeliveryOrderPaymentDetail]
					SET IdHeaderRecolection = @SchedulePickupId
					WHERE DopId = @dopdId

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
						,(SELECT IdServiceStatus FROM CatServiceStatus WHERE [Name] = 'Asignado a Ruta')
						,NULL
						,NULL
						,(SELECT
								IdSubTypeServiceManagment
							FROM SubTypeServiceManagment
							WHERE [Name] = 'Recolección')
						,NULL
						,1
					FROM RouteAssigment ra WITH (NOLOCK)
					WHERE ra.IdRouteAssigment = @RouteAssignmentId

				SET @ServiceManagementId = SCOPE_IDENTITY()

				IF NOT EXISTS (SELECT
						1
					FROM EventService es
					WHERE es.ServiceManagementId = @ServiceManagementId
					AND es.ServiceStatusId = @ServiceStatus
					AND es.RowStauts = 1)
				BEGIN
					INSERT INTO EventService (ServiceManagementId,
					ServiceStatusId,
					RowStauts,
					TokenCreated,
					DateCreated,
					Observations)
						VALUES (@ServiceManagementId, @ServiceStatus, 1, @Token, GETDATE(), NULL);
				END

				DELETE FROM @GuidesIterate
				WHERE GuideSerie = @GuideSerie
					AND GuideNumber = @GuideNumber;
			END

			DECLARE @StatusOrderId TINYINT = ( SELECT
					StatusOrderId
				FROM StatusOrder
				WHERE OrderDescription = 'Declarado para Devolución')

			UPDATE do
			SET do.StatusOrderId = @StatusOrderId
				,do.IsLastMileReturn = 1
				,do.TokenUpdated = @Token
				,do.DateUpdated = GETDATE()
				,do.Dispatched_Date = GETDATE()
			FROM DeliveryOrder do WITH (NOLOCK)
			INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
				ON do.Guide_Serie = trpd.GuideSerie
				AND do.Guide_Number = trpd.GuideNumber
			INNER JOIN TSERoutePreparationHeader trph WITH (NOLOCK)
				ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
				AND trph.IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
			WHERE trpd.RowStatus = 1
			AND trph.RowStatus = 1
			AND (do.Pieces_Dry + do.Pieces_Cold) > 1

			UPDATE dop
			SET dop.StatusOrderId = @StatusOrderId
			FROM DeliveryOrderPiece dop WITH (NOLOCK) 
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON do.Guide_Serie = dop.GuideSerie
				AND do.Guide_Number = dop.GuideNumber
			INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
				ON do.Guide_Serie = trpd.GuideSerie
				AND do.Guide_Number = trpd.GuideNumber
			INNER JOIN TSERoutePreparationHeader trph WITH (NOLOCK)
				ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
				AND trph.IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
			WHERE trpd.RowStatus = 1
			AND trph.RowStatus = 1
			AND (do.Pieces_Dry + do.Pieces_Cold) > 1

			INSERT INTO DeliveryOrderDetail ([Guide_Serie],
			[Guide_Number],
			[StatusOrderId],
			[UserCreated],
			[DateCreated],
			[DateCreatedInSystem],
			[Observations],
			[Temperature_Celsius],
			[PieceId])
				SELECT
					trpd.GuideSerie
					,trpd.GuideNumber
					,@StatusOrderId
					,@Token
					,GETDATE()
					,GETDATE()
					,NULL
					,NULL
					,NULL
				FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
				INNER JOIN TSERoutePreparationHeader trph WITH (NOLOCK)
					ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
						AND trph.IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = trpd.GuideSerie
					AND do.Guide_Number = trpd.GuideNumber
				WHERE trpd.RowStatus = 1
				AND trph.RowStatus = 1
				AND (do.Pieces_Dry + do.Pieces_Cold) > 1
			
			UPDATE TSERoutePreparationHeader
			SET  HasFirstDeliveryProccess = 1
				,TokenUpdated = @Token
				,DateUpdated = GETDATE()
			WHERE IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
			AND RowStatus = 1

			COMMIT TRANSACTION 

			SELECT
			'1' 'ResultCode'
			,'Registros actualizados correctamente.' 'Description'

		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION

			SELECT
			'-2' 'ResultCode'
			,'No se encontraron registroso o no se encuentra en un flujo válido.' 'Description'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT
			'-1' 'ResultCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END