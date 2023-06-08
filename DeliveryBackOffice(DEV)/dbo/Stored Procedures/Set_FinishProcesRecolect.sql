create PROCEDURE Set_FinishProcesRecolect
@IdRoute INT,
@DateRoute DATE,
--@IdCurier INT,
--@IdVehicle INT,
@Token VARCHAR (50),
@UrlSignature VARCHAR(500)

AS
 DECLARE @RouteAssigment INT;
 DECLARE @IdCourier INT;
 DECLARE @IdVehicle INT;
BEGIN
	DECLARE @RouteAssignment INT;

	SET @IdCourier = (SELECT IdCatRoute FROM TSERoutePreparationHeader WHERE IdCatRoute =@IdRoute AND RowStatus = 1)
	SET @IdVehicle = (SELECT SenderReceiverId FROM TSERoutePreparationHeader WHERE IdCatRoute =@IdRoute AND RowStatus = 1 )
			
			IF NOT EXISTS (SELECT
					IdRouteAssigment
				FROM [DeliveryBackOffice].[dbo].[RouteAssigment]  WITH(NOLOCK) 
				WHERE IdRoute = @IdRoute
				AND DateOfRoute = @DateRoute
				AND [RowStatus] = 1)
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[RouteAssigment] 
				(IdRoute, DateOfRoute, RowStatus, TokenCreated, DateCreated)
					VALUES (@IdRoute, @DateRoute, 1, @Token, GETDATE())
				SET @RouteAssignment = SCOPE_IDENTITY()
			END
			ELSE
            BEGIN
                SELECT
					@RouteAssignment = IdRouteAssigment
				FROM [DeliveryBackOffice].[dbo].[RouteAssigment]  WITH(NOLOCK) 
				WHERE IdRoute = @IdRoute
				AND DateOfRoute = @DateRoute
				AND [RowStatus] = 1
            END
			INSERT INTO 
				[DeliveryBackOffice].[dbo].[SchedulePickup] 
				(StartDate, EndDate, RowStatus, TokenCreated,
						DateCreated, SenderId, SenderName, SenderPhone
						, AddressPickup, TownshipId)
			SELECT
				TOP 1
					GETDATE()
					,GETDATE()
					,1
					,@token
					,GETDATE()
					,[DO].[Sender_ID]
					,CONCAT([car].[CodeRoute], ' - ', [vpc].[DescriptionOfClient])
					,[vpc].[Phone]
					,[vpc].[Address]
					,[vpc].[IdTownship]
			FROM
				[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] tse
				INNER JOIN
					[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] tsed
					ON
						tse.[IDTSERoutePreparationHeader] = [tsed].[TSERoutePreparationHeaderID]
				LEFT JOIN 
					[DeliveryBackOffice].[dbo].[CatRoute] car
					ON 
						car.IdRoute = tse.IdCatRoute		
				INNER JOIN
					[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
					ON
						[DO].[Guide_Serie] = [tsed].[GuideSerie] AND [DO].[Guide_Number] = [tsed].[GuideNumber]
				INNER JOIN
					[dbo].[VisitPointClient] vpc
					ON
						[vpc].[CodeOfReference] = [DO].[Sender_ID]
			WHERE
				[tse].[IdCatRoute] = @idRoute
				AND
                [tse].[RowStatus] = 1
			DECLARE @SchedulePickup INT;
			SET @SchedulePickup = SCOPE_IDENTITY()

			INSERT INTO [dbo].[ServiceManagement]
			(
			    [IdPuCourrier],
			    [CiPuDate],
			    [CoPuDate],
			    [IdPuRouteAssigment],
			    [IdSchedulePickup],
			    [RowStatus],
			    [TokenCreated],
			    [DateCreated],
			    [ServiceStatusId],
			    [PuSignaturePath],
			    [SubTypeServiceManagmentId]
			)
			VALUES
			(   
				@IdCourier,      -- IdPuCourrier - int
			    GETDATE(),      -- CiPuDate - datetime
			    GETDATE(),      -- CoPuDate - datetime
			    @RouteAssignment,      -- IdPuRouteAssigment - int
			    @SchedulePickup,      -- IdSchedulePickup - bigint
			    1,      -- RowStatus - bit
			    @token,        -- TokenCreated - varchar(50)
			    GETDATE(), -- DateCreated - datetime
			    3,      -- ServiceStatusId - int
			    @UrlSignature,      -- PuSignaturePath - nvarchar(250)
			    1      -- SubTypeServiceManagmentId - int
			)
			
			UPDATE
				[DOPD]
			set
				[DOPD].[IdHeaderRecolection] = @SchedulePickup
				,[DOPD].[TokenUpdated] = @Token
				,[DOPD].[DateUpdated] = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] tse
				INNER JOIN
					[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] tsed
					ON
						tse.[IDTSERoutePreparationHeader] = [tsed].[TSERoutePreparationHeaderID]
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD
					ON
						DOPD.[GuideSerie] = [tsed].[GuideSerie]
						AND
						[DOPD].[GuideNumber] = [tsed].[GuideNumber]
			WHERE
				[tse].[IdCatRoute] = @IdRoute


END