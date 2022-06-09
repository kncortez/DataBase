
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Desasignación de un servicio a una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_SchedulePickUp]
		@startDate as datetime,
		@endDate as datetime,
		@estimateWeight as decimal,
		@quantityRegular as int,
		@quantityOverDimensioned as int,
		@token as varchar(50),
		@idSender as int,
		@nameSender as varchar(200),
		@phoneSender as varchar(50),
		@idHub as int,
		@addressPickUp as varchar(500),
		@idTownship as int,
		@Guides NVARCHAR(MAX),
		@TotalAmount DECIMAL(16,2) = 0,
		@PaymentTime VARCHAR(55) = NULL,
		@TypeVehicle INT = 2, -- 2 Panel
		@IsScheduled BIT = 1
AS
BEGIN
	DECLARE @amountPickUp as int
	DECLARE @idSchedulePickUp as int
	DECLARE @idSchedule as int
	DECLARE @GuideSerie NVARCHAR(2)
	DECLARE @GuideNumber INT
	DECLARE @dopdId INT 
	DECLARE @CatPaymentTimeId INT
	DECLARE @GuidesIterate TABLE (
		GuideSerie NVARCHAR(2)
	   ,GuideNumber INT
	);
	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;


	BEGIN TRANSACTION
	BEGIN TRY
		IF @Guides = ''
			SET @Guides = NULL

		SELECT
			SUBSTRING(Item, 1, 2) ItemSerie
		   ,SUBSTRING(Item, 3, LEN(Item)) ItemNumber INTO #listGuides
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@Guides, ',')

		INSERT INTO @GuidesIterate
		SELECT ItemSerie, ItemNumber
		FROM #listGuides

		IF @PaymentTime IS NOT NULL
			SET @CatPaymentTimeId = (SELECT TimePlaId FROM CatPaymentTime WHERE TimePlaName = @PaymentTime)

		SELECT @amountPickUp = Value FROM [DeliveryBackOffice].[dbo].[CatToCharge] WHERE IdToCharge = 1;

		IF @idHub != ''
		BEGIN
			IF @idTownship != ''
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickup] (StartDate,EndDate,EstimatedWeight,IsLargePackage,QuantityRegularPackages,
				QuantityOverDimensionedPackage,	RowStatus,TokenCreated,DateCreated,SenderId,SenderName,SenderPhone,IdHubLogistics,AmountPickup,
				IdSourcePlataform,AddressPickup,TownshipId, TypeVehicleId, IsScheduled)
				VALUES (@startDate,@endDate,@estimateWeight,0,@quantityRegular,@quantityOverDimensioned,1,@token,GETDATE(),@idSender,@nameSender,
				@phoneSender,@idHub,@amountPickUp,2,@addressPickUp,@idTownship, @TypeVehicle, @IsScheduled)
			END
			ELSE
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickup] (StartDate,EndDate,EstimatedWeight,IsLargePackage,QuantityRegularPackages,
				QuantityOverDimensionedPackage,	RowStatus,TokenCreated,DateCreated,SenderId,SenderName,SenderPhone,IdHubLogistics,AmountPickup,
				IdSourcePlataform,AddressPickup, TypeVehicleId, IsScheduled)
				VALUES (@startDate,@endDate,@estimateWeight,0,@quantityRegular,@quantityOverDimensioned,1,@token,GETDATE(),@idSender,@nameSender,
				@phoneSender,@idHub,@amountPickUp,2,@addressPickUp, @TypeVehicle, @IsScheduled)
			END
		END
		ELSE
		BEGIN
			IF @idTownship != ''
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickup] (StartDate,EndDate,EstimatedWeight,IsLargePackage,QuantityRegularPackages,
				QuantityOverDimensionedPackage,	RowStatus,TokenCreated,DateCreated,SenderId,SenderName,SenderPhone,AmountPickup,
				IdSourcePlataform,AddressPickup,TownshipId, TypeVehicleId, IsScheduled)
				VALUES (@startDate,@endDate,@estimateWeight,0,@quantityRegular,@quantityOverDimensioned,1,@token,GETDATE(),@idSender,@nameSender,
				@phoneSender,@amountPickUp,2,@addressPickUp,@idTownship, @TypeVehicle, @IsScheduled)
			END
			ELSE
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickup] (StartDate,EndDate,EstimatedWeight,IsLargePackage,QuantityRegularPackages,
				QuantityOverDimensionedPackage,	RowStatus,TokenCreated,DateCreated,SenderId,SenderName,SenderPhone,AmountPickup,
				IdSourcePlataform,AddressPickup, TypeVehicleId, IsScheduled)
				VALUES (@startDate,@endDate,@estimateWeight,0,@quantityRegular,@quantityOverDimensioned,1,@token,GETDATE(),@idSender,@nameSender,
				@phoneSender,@amountPickUp,2,@addressPickUp, @TypeVehicle, @IsScheduled)
			END
		END

		SELECT  @idSchedulePickUp =  IDENT_CURRENT('[DeliveryBackOffice].[dbo].[SchedulePickup]')

		--Asignar el SchedulePickup en la DeliveryOrderPaymentDetail
		WHILE EXISTS (SELECT
				TOP 1 1
			FROM @GuidesIterate)
		BEGIN
			SELECT TOP 1
				@GuideSerie = GuideSerie
			   ,@GuideNumber = GuideNumber
			FROM @GuidesIterate

			--Validar que tenga registro en la DeliveryOrderPaymentDetail sino lo crea
			SELECT
				@dopdId = dopd.DopId
			FROM DeliveryOrderPaymentDetail dopd
			WHERE dopd.GuideSerie = @GuideSerie AND dopd.GuideNumber = @GuideNumber

			IF @dopdId IS NULL
			BEGIN

				INSERT INTO [dbo].[DeliveryOrderPaymentDetail]
						   ([GuideNumber]
						   ,[GuideSerie]
						   ,[PayTypeId]
						   ,[TypeofInOutMoneyId]
						   ,[TimePlaId]
						   ,[amount]
						   ,[TokenCreated]
						   ,[DateCreated]
						   ,[TokenUpdated]
						   ,[DateUpdated]
						   ,[PaymentRecollections]
						   ,[PaymentNow]
						   ,[PaymentDelivery]
						   ,[StartDate]
						   ,[EndDate]
						   ,[ShipmentCompleted]
						   ,[RecollectionCompleted]
						   ,[PaidGuide]
						   ,[TransaccionFAC]
						   ,[IdHeaderRecolection]
						   ,[RecolectNow]
						   ,[RecolectDelivery]
						   ,[RecolectPayment])
						   --,[TypeService]
						   --,[IdAccount])
					 SELECT
						   @GuideNumber
						   ,@GuideSerie
						   ,CASE WHEN do.IsCollect = 1 THEN ( SELECT
									PayTypeId
								FROM CatPaymentType
								WHERE PayTypeAbrev = 'COLLT')
							WHEN cu.ConditionOfPaymentID > 1 THEN ( SELECT
									PayTypeId
								FROM CatPaymentType
								WHERE PayTypeAbrev = 'CREDT')
							ELSE ( SELECT
									PayTypeId
								FROM CatPaymentType
								WHERE PayTypeAbrev = 'CONT')
							END
						   ,CASE WHEN do.IsCollect = 1 THEN 1
							WHEN cu.ConditionOfPaymentID > 1 THEN 8
							ELSE 1
							END
						   ,CASE WHEN do.IsCollect = 1 THEN ( SELECT
									TimePlaId
								FROM CatPaymentTime
								WHERE TimePlaAbrev = 'DEST')
							WHEN cu.ConditionOfPaymentID > 1 THEN ( SELECT
									TimePlaId
								FROM CatPaymentTime
								WHERE TimePlaAbrev = 'POST')
							ELSE ( SELECT
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
						   ,@idSchedulePickUp
						   ,NULL
						   ,NULL
						   ,NULL
						   --,NULL
						   --,NULL
					FROM DeliveryOrder do
					JOIN Customer cu
						ON cu.IdCustomer = 
						(
							SELECT TOP 1
									ISNULL(do.IdCustomer, vpc.CustomerID)
							FROM dbo.VisitPointClient vpc
							WHERE vpc.CodeOfReference = do.Sender_ID
						)
					WHERE do.Guide_Serie = @GuideSerie
						AND do.Guide_Number = @GuideNumber
			END
			ELSE
				UPDATE [dbo].[DeliveryOrderPaymentDetail]
				SET IdHeaderRecolection = @idSchedulePickUp
				WHERE DopId = @dopdId

			-- cambiar statusorder 
			UPDATE [dbo].[DeliveryOrder]
			SET	StatusOrderId = 1
			WHERE Guide_Serie = @GuideSerie
				AND Guide_Number = @GuideNumber

			-- insertar checkpoint
			INSERT INTO [dbo].[DeliveryOrderDetail] ([Guide_Serie]
				, [Guide_Number]
				, [StatusOrderId]
				, [UserCreated]
				, [DateCreated]
				, [DateCreatedInSystem]
				, [Observations]
				, [Temperature_Celsius]
				, [PieceId]
				, [RowStatus])
				VALUES (@GuideSerie, @GuideNumber, 1, @token, GETDATE(), GETDATE(), NULL, NULL, NULL, 'TRUE')




			-- se elimina la guía de la tabla temporal
			DELETE FROM @GuidesIterate
			WHERE GuideSerie = @GuideSerie
				AND GuideNumber = @GuideNumber;
		END

		IF NOT EXISTS(SELECT IdSchedulePickup FROM [DeliveryBackOffice].[dbo].[ServiceManagement] 
					  WHERE IdSchedulePickup=@idSchedulePickUp)
		BEGIN
			INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement] (IdSchedulePickup,RowStatus,TokenCreated,DateCreated,ServiceStatusId, Amount, CatPaymentTimeId)
			VALUES(@idSchedulePickUp,1,@token,GETDATE(),1,@TotalAmount,@CatPaymentTimeId)
		
			SELECT  @idSchedule =  IDENT_CURRENT('[DeliveryBackOffice].[dbo].[ServiceManagement]')

			INSERT INTO [DeliveryBackOffice].[dbo].[EventService] (ServiceManagementId,ServiceStatusId,RowStauts,TokenCreated,DateCreated)
			VALUES(@idSchedule,1,1,@token,GETDATE() )
		END
		ELSE
			DECLARE @LastServiceManagement AS TABLE(
				IdServiceManagement INT,
				DateOfSM DATETIME
			)

			UPDATE [dbo].[ServiceManagement]
			SET Amount = @TotalAmount
				,CatPaymentTimeId = @CatPaymentTimeId
				,TokenUpdated = @token
				,DateUpdated = GETDATE()
			OUTPUT inserted.IdServiceManagement, inserted.DateCreated INTO @LastServiceManagement(IdServiceManagement,DateOfSM)
			WHERE IdSchedulePickup = @idSchedulePickUp

			SELECT
				TOP 1
					@idSchedule = LSM.IdServiceManagement
			FROM
				@LastServiceManagement LSM
			ORDER BY
				LSM.DateOfSM DESC
		
		IF @@TRANCOUNT > 0 
		BEGIN
			COMMIT TRANSACTION;

			SELECT
				1 [blnResult]
			   ,'Registros guardados correctamente' [Description]
			   , @idSchedule [IdService]
			   ,@@TRANCOUNT [NumTransferID]
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION;

			SELECT
				-1 [blnResult]
			   ,'Registros no guardados' [Description]
			   ,@@TRANCOUNT [NumTransferID]
		END

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT
			0 [blnResult]
		   ,ERROR_NUMBER() [ErrorNumber]
		   ,ERROR_SEVERITY() [ErrorSeverity]
		   ,ERROR_STATE() [ErrorState]
		   ,ERROR_PROCEDURE() [ErrorProcedure]
		   ,ERROR_LINE() [ErrorLine]
		   ,ERROR_MESSAGE() [ErrorMessage];
	END CATCH
END
