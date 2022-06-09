
-- =============================================
-- Author:		<Sazo, Cesar>
-- Create date: <2021-12-28>
-- Description:	<Crea un registro en la tabla SchedulePickup y asigna una ruta a un servicio>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_set_AssigmentRouteService]
	@token AS VARCHAR(50),
	@idRoute AS INT,
	@dateRoute AS DATE,
	@TblRoutesPreparation AS TblRoutesPreparation READONLY
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY

		--Deshabilitar registros para ruta y fecha elegida
		UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
		SET AssigmentStatus = '0',
		RowStatus=0,
		TokenUpdated = @token,
		DateUpdated = GETDATE()
		FROM [DeliveryBackOffice].[dbo].[SchedulePickup] spu INNER JOIN @TblRoutesPreparation sp
		ON spu.StartDate = sp.StartDate AND spu.EndDate = sp.EndDate AND CONVERT(date, spu.DateCreated) = CONVERT(date, GETDATE()) AND
		spu.SenderName = sp.nameSender AND spu.AddressPickup = sp.addressPickUp
		WHERE sp.CodeOfReference = -1;
		
		CREATE TABLE #TblRouteData (
			rwNumber [INT],StartDate [DATETIME],EndDate [DATETIME],CodeOfReference [INT],nameSender [VARCHAR](200),
			phoneSender [VARCHAR](50),addressPickUp [VARCHAR](500),idTownship [INT],OrderP [SMALLINT]
		);

		--Obtener solo registros validos para hacer la transaccion
		INSERT INTO #TblRouteData
		SELECT sp.rwNumber,sp.StartDate,sp.EndDate,sp.CodeOfReference,sp.nameSender,sp.phoneSender,sp.addressPickUp,sp.idTownship,sp.OrderP
		FROM @TblRoutesPreparation sp
		WHERE sp.CodeOfReference > 0;
				
		DECLARE @counterData AS INT
		DECLARE @indexData AS INT
		SET @counterData = (SELECT COUNT(1) FROM #TblRouteData)
		SET @indexData = 1
		
		WHILE (@indexData <= @counterData)
		BEGIN
			
			--Validar si se debe insertar o actualizar
			DECLARE @FlagInsert AS BIT = 0
			IF EXISTS(SELECT spu.SchedulePickupId
						FROM [dbo].[SchedulePickup] spu
						INNER JOIN #TblRouteData sp ON spu.SenderId = sp.CodeOfReference
						WHERE spu.StartDate = sp.StartDate AND
						spu.EndDate = sp.EndDate AND
						CONVERT(date, spu.DateCreated) = CONVERT(date, GETDATE()) AND
						spu.SenderId = sp.CodeOfReference AND 
						spu.SenderName = sp.nameSender AND
						spu.AddressPickup = sp.addressPickUp AND
						sp.rwNumber = @indexData)
			BEGIN
				SET @FlagInsert = 1
			END

			--Se agregan los registros en la tabla SchedulePickup
			INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickup] (StartDate, EndDate, RowStatus, TokenCreated,
						DateCreated, SenderId, SenderName, SenderPhone, IdSourcePlataform, AddressPickup, TownshipId, IsScheduled)
			SELECT sp.StartDate, sp.EndDate, 1, @token, GETDATE(), sp.CodeOfReference, sp.nameSender, sp.phoneSender, 2, sp.addressPickUp, sp.idTownship, 1
			FROM #TblRouteData sp
			WHERE sp.rwNumber = @indexData AND 
			@FlagInsert = 0;

			IF NOT EXISTS (SELECT
					IdRouteAssigment
				FROM [DeliveryBackOffice].[dbo].[RouteAssigment] NOLOCK
				WHERE IdRoute = @idRoute
				AND DateOfRoute = @dateRoute)
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[RouteAssigment] (IdRoute, DateOfRoute, RowStatus, TokenCreated, DateCreated)
					VALUES (@idRoute, @dateRoute, 1, @token, GETDATE())
			END

			--*
			DECLARE @idSchedulePickup AS INT;

			IF (@FlagInsert = 0)
			BEGIN
				SET @idSchedulePickup = (SELECT IDENT_CURRENT('SchedulePickup'))
			END
			ELSE
			BEGIN 
				SELECT @idSchedulePickup = spu.SchedulePickupId
						FROM [dbo].[SchedulePickup] spu
						INNER JOIN #TblRouteData sp ON spu.SenderId = sp.CodeOfReference
						WHERE spu.StartDate = sp.StartDate AND
						spu.EndDate = sp.EndDate AND
						CONVERT(date, spu.DateCreated) = CONVERT(date, GETDATE()) AND
						spu.SenderId = sp.CodeOfReference AND 
						spu.SenderName = sp.nameSender AND
						spu.AddressPickup = sp.addressPickUp AND
						sp.rwNumber = @indexData
			END

			DECLARE @idRouteAssigment AS INT
			DECLARE @idSchedule AS INT

			SET @idRouteAssigment = (SELECT
										IdRouteAssigment
									FROM [DeliveryBackOffice].[dbo].[RouteAssigment] NOLOCK
									WHERE IdRoute = @idRoute
									AND DateOfRoute = @dateRoute)
			
			--OBTENIENDO CAMPOS DE INFORMACION DEL CLIENTE
			DECLARE @IDCUSTOMER INT;					--ID DEL CLIENTE
			DECLARE @CONDITIONOFPAYMENTID INT;			--TIEMPO DE PAGO
			SELECT 
				@IDCUSTOMER=CU.IdCustomer,
				@CONDITIONOFPAYMENTID=ConditionOfPaymentID 
			FROM DBO.VisitPointClient VPC 
				LEFT JOIN DBO.Customer CU on VPC.CustomerID=CU.IdCustomer
				WHERE CodeOfReference=(select CodeOfReference from #TblRouteData where rwNumber = @indexData);

			DECLARE @TIMETOPAY INT =NULL;
			SELECT @TIMETOPAY=(SELECT TimePlaId FROM CatPaymentTime WHERE TimePlaName = 'Post-Venta')
				FROM DBO.CatConditionOfPayment WHERE IdConditionOfPayment=@CONDITIONOFPAYMENTID AND ConditionOfPayment <>'CONTADO';

			IF (@FlagInsert = 1) AND EXISTS(SELECT IdServiceManagement 
							FROM [DeliveryBackOffice].[dbo].[ServiceManagement] NOLOCK
							WHERE IdSchedulePickup=@idSchedulePickup)
				BEGIN
					SELECT
						@idSchedule = IdServiceManagement
					FROM [DeliveryBackOffice].[dbo].[ServiceManagement] NOLOCK
					WHERE IdSchedulePickup = @idSchedulePickup
				
					UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement] 
					SET IdPuRouteAssigment = @idRouteAssigment, 
					ServiceStatusId=2,
					TokenUpdated = @token,
					DateUpdated = GETDATE(),
					[Order] = (SELECT TOP (1) OrderP FROM #TblRouteData ttbl WHERE ttbl.rwNumber = @indexData ORDER BY ttbl.rwNumber ASC),
					CatPaymentTimeId=ISNULL( @TIMETOPAY,CatPaymentTimeId)
					WHERE IdServiceManagement = @idSchedule
				END
				ELSE
				BEGIN
					INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement] (IdPuRouteAssigment, IdSchedulePickup, RowStatus, TokenCreated, DateCreated, ServiceStatusId, [Order],CatPaymentTimeId)
						VALUES (@idRouteAssigment, @idSchedulePickup, 1, @token, GETDATE(), 2, (SELECT TOP (1) OrderP FROM #TblRouteData ttbl WHERE ttbl.rwNumber = @indexData ORDER BY ttbl.rwNumber ASC),@TIMETOPAY)

					SELECT
						@idSchedule = IdServiceManagement
					FROM [DeliveryBackOffice].[dbo].[ServiceManagement] NOLOCK
					WHERE IdSchedulePickup = @idSchedulePickup
				END
			--*
			UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
			SET AssigmentStatus = '1', IsScheduled = 1
			WHERE SchedulePickupId = @idSchedulePickup

			IF @idSchedule IS NOT NULL
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[EventService] (ServiceManagementId, ServiceStatusId, RowStauts,
				TokenCreated, DateCreated)
					VALUES (@idSchedule, 2, 1, @token, GETDATE())
			END
			
			SET	@indexData = @indexData + 1
			
		END--ENDWHILE

		SELECT 1 AS 'SUCCESS'

	END TRY
	BEGIN CATCH

		SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;
		
		ROLLBACK TRANSACTION;

	END CATCH

	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;
	END

END
