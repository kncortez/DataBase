-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recoleccion de guias, su funcion es insertar y actualizar informacion de las tablas DeliveryOrder, DeliveryOrderPaymentDetail y SchedulePickup >
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2022-07-20>
-- Description:	< Cambio de agrupaciones para evitar duplicados en servicios de recolección (Falsos positivos) >
-- =============================================
CREATE PROCEDURE [dbo].[SetRecolectionRequest]
    @TblDeliveryOrdersList AS [TblDeliveryOrdersList2] READONLY,
    @Iscollected BIT = true,
    @status INT = 15,
    @ShipmentCompleted BIT = true,
    @IdStatus AS INT = 15,
    @Token AS NVARCHAR(100),
    @IdAccount AS INT = NULL,
    @InstructionsCurrier AS NVARCHAR(300) = NULL,
    @PartDimensions AS INT = 1,
    @Regularpiezer AS INT = 1,
    @StartDate AS DATETIME = NULL,
    @EndDate AS DATETIME = NULL,
    @WeightEstimated AS DECIMAL(18, 2) = NULL,
    @BigPackages AS BIT = false,
    @ValidateFilter AS INT = 0,
    @RecollectionLatitude AS DECIMAL(18, 15) = 0,
    @RecollectionLongitude AS DECIMAL(18, 15) = 0,
    @DeliveryLatitude AS DECIMAL(18, 15) = 0,
    @DeliveryLongitude AS DECIMAL(18, 15) = 0,
    @IdUser INT = 0,
    @TypeVehicleId INT = NULL
AS
BEGIN
    IF (@ValidateFilter = 1)
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY

            DECLARE @jsonResult2 NVARCHAR(MAX);

            INSERT INTO dbo.DeliveryOrderPaymentDetail
            (
                [GuideNumber],
                [GuideSerie],
                [PayTypeId],
                [TypeofInOutMoneyId],
                [TimePlaId],
                [amount],
                [PaymentRecollections],
                [PaymentNow],
                [PaymentDelivery],
                [StartDate],
                [EndDate],
                [ShipmentCompleted],
                [RecollectionCompleted],
                [PaidGuide],
                [TokenCreated],
                [DateCreated],
                [TokenUpdated],
                [DateUpdated],
                [TransaccionFAC],
                [IdHeaderRecolection]
            )
            SELECT Guide_Number,
                   Guide_Serie,
                   IdTypePayment,
                   IdWayToPayment,
                   IdTimePayment,
                   AmmountToPay,
                   tdop.PaymentRecollections,
                   tdop.PaymentNow,
                   tdop.PaymentDelivery,
                   NULL,
                   NULL,
                   tdop.ShipmentCompleted,
                   tdop.RecollectionCompleted,
                   tdop.PaidGuide,
                   @Token,
                   GETDATE(),
                   NULL,
                   NULL,
                   NULL,
                   NULL
            FROM @TblDeliveryOrdersList tdop;
        END TRY
        BEGIN CATCH
            DECLARE @jsonOutput NVARCHAR(MAX);
            SET @jsonOutput =
            (
                SELECT ''
                       + STUFF(
                                  (
                                      SELECT ',{"Status":"' + ERROR_MESSAGE() + '"}' FOR XML PATH(''), TYPE
                                  ).value('.', 'varchar(max)'),
                                  1,
                                  1,
                                  ''
                              ) + ''
            );

            SELECT ('[' + @jsonOutput + ']') jsonOutput;
            ROLLBACK TRANSACTION;

            INSERT INTO dbo.RoutePreparationLogError
            (
                ErrorDescription,
                ErrorNumber,
                ErrorProcedure,
                ErrorLine,
                GuideSerie,
                GuideNumber,
                TokenCreated,
                DateCreated
            )
            VALUES
            (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)),
             ERROR_LINE(), 0, 0, CONCAT('Token: ', @Token, ' Account: ', @IdAccount, ' User: ', @IdUser), GETDATE());

        END CATCH;

        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;

            DECLARE @jsonOutput1 NVARCHAR(MAX);
            SET @jsonOutput1 =
            (
                SELECT '' + STUFF(
                                     (
                                         SELECT ',{"Status":"Cambios realizados exitosamente"}'
                                         FOR XML PATH(''), TYPE
                                     ).value('.', 'varchar(max)'),
                                     1,
                                     1,
                                     ''
                                 ) + ''
            );

            SELECT ('[' + @jsonOutput1 + ']') jsonOutput1;
        END;

    END;

    IF (@ValidateFilter = 2)
    BEGIN

        -- MODIFICACIÓN 04/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
        -- Variable que indicará si ya existe una transacción con la guía actual
        DECLARE @ValidateTransaction INT =
                (
                    SELECT DopId
                    FROM dbo.DeliveryOrderPaymentTransaction do
                        INNER JOIN @TblDeliveryOrdersList tpo
                            ON do.GuideNumber = tpo.Guide_Number
                               AND do.GuideSerie = tpo.Guide_Serie
                               AND do.TypeServiceId = tpo.IdTypeService
                );

        IF (@ValidateTransaction IS NULL)
        BEGIN
            BEGIN TRANSACTION;
            BEGIN TRY
                /*fecha inicio cambio 18/02/2020*/
                UPDATE dbo.DeliveryOrder
                SET PriceShippment = t.PriceShippment,
                    StatusOrderId = @IdStatus,
                    IsCollect = t.IsCollect
                FROM dbo.DeliveryOrder ord with (nolock)
                    INNER JOIN @TblDeliveryOrdersList t
                        ON t.Guide_Number = ord.Guide_Number
                           AND t.Guide_Serie = ord.Guide_Serie;
                /*fecha fin 18/02/2020*/
                UPDATE dbo.DeliveryOrderPaymentDetail
                SET ShipmentCompleted = t.ShipmentCompleted,
                    PayTypeId = t.IdTypePayment,
                    TypeofInOutMoneyId = t.IdWayToPayment,
                    TimePlaId = t.IdTimePayment
                FROM dbo.DeliveryOrderPaymentDetail pay
                    INNER JOIN @TblDeliveryOrdersList t
                        ON (
                               t.Guide_Number = pay.GuideNumber
                               AND t.Guide_Serie = pay.GuideSerie
                           );


                IF (@IdAccount != 0)
                BEGIN

                    DECLARE @VistitPointUser INT =
                            (
                                SELECT CodeOfReference
                                FROM DeliveryBackOffice.dbo.VisitPointClient VPC
                                    INNER JOIN VisitPointByUser VPU WITH (NOLOCK)
                                        ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
                                           AND VPU.RowStatus = 1
                                    INNER JOIN RegisterUser ru WITH (NOLOCK)
                                        ON VPU.RegisterUserID = ru.UsrIdUser
                                           AND ru.UsrRowStatus = 1
                                    INNER JOIN [dbo].[RolByUserByAccount] rua
                                        ON rua.RuaIdUser = ru.UsrIdUser
                                WHERE rua.RuaIdAccount = @IdAccount
                            );

                    INSERT INTO dbo.DeliveryOrderPaymentTransaction
                    (
                        [GuideNumber],
                        [GuideSerie],
                        [PayTypeId],
                        [TypeofInOutMoneyId],
                        [TimePlaId],
                        [amount],
                        [PaymentRecollections],
                        [PaymentNow],
                        [PaymentDelivery],
                        [StartDate],
                        [EndDate],
                        [ShipmentCompleted],
                        [RecollectionCompleted],
                        [PaidGuide],
                        [TokenCreated],
                        [DateCreated],
                        [TokenUpdated],
                        [DateUpdated],
                        [TransaccionFAC],
                        [IdHeaderRecolection],
                        [TypeServiceId],
                        [AccountId],
                        [CODAmountProcess],
                        [Fel],
                        [VisitPoint]
                    )
                    SELECT Guide_Number,
                           Guide_Serie,
                           IdTypePayment,
                           IdWayToPayment,
                           IdTimePayment,
                           tdop.PriceShippment,
                           tdop.PaymentRecollections,
                           tdop.PaymentNow,
                           tdop.PaymentDelivery,
                           NULL,
                           NULL,
                           tdop.ShipmentCompleted,
                           tdop.RecollectionCompleted,
                           tdop.PaidGuide,
                           @Token,
                           GETDATE(),
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           tdop.IdTypeService,
                           IIF(@IdAccount = 0, NULL, @IdAccount),
                           tdop.CODAmountProccess,
                           NULL,
                           IIF(@VistitPointUser = 0, NULL, @VistitPointUser)
                    FROM @TblDeliveryOrdersList tdop
                    WHERE tdop.PriceShippment != 0
                          OR tdop.CODAmountProccess != 0;
                END;
            END TRY
            BEGIN CATCH
                DECLARE @jsonOutput2 NVARCHAR(MAX);
                SET @jsonOutput2 =
                (
                    SELECT ''
                           + STUFF(
                                      (
                                          SELECT ',{"Status":"' + ERROR_MESSAGE() + '"}' FOR XML PATH(''), TYPE
                                      ).value('.', 'varchar(max)'),
                                      1,
                                      1,
                                      ''
                                  ) + ''
                );

                SELECT ('[' + @jsonOutput2 + ']') jsonOutput2;
                ROLLBACK TRANSACTION;

                INSERT INTO dbo.RoutePreparationLogError
                (
                    ErrorDescription,
                    ErrorNumber,
                    ErrorProcedure,
                    ErrorLine,
                    GuideSerie,
                    GuideNumber,
                    TokenCreated,
                    DateCreated
                )
                VALUES
                (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)),
                 ERROR_LINE(), 0, 0, CONCAT('Token: ', @Token, ' Account: ', @IdAccount, ' User: ', @IdUser), GETDATE());

            END CATCH;

            IF @@TRANCOUNT > 0
            BEGIN
                COMMIT TRANSACTION;

                DECLARE @jsonOutput3 NVARCHAR(MAX);
                SET @jsonOutput3 =
                (
                    SELECT '' + STUFF(
                                         (
                                             SELECT ',{"Status":"Cambios actualizados exitosamente"}'
                                             FOR XML PATH(''), TYPE
                                         ).value('.', 'varchar(max)'),
                                         1,
                                         1,
                                         ''
                                     ) + ''
                );

                SELECT ('[' + @jsonOutput3 + ']') jsonOutput3;
            END;
        END;
        ELSE
        BEGIN
            DECLARE @jsonOutM NVARCHAR(MAX);
            SET @jsonOutM =
            (
                SELECT '' + STUFF(
                                     (
                                         SELECT ',{"Status":"La guía ya ha sido transaccionada"}'
                                         FOR XML PATH(''), TYPE
                                     ).value('.', 'varchar(max)'),
                                     1,
                                     1,
                                     ''
                                 ) + ''
            );

            SELECT ('[' + @jsonOutM + ']') jsonOutM;
        END;
    -- FIN MODIFICACIÓN
    END;

    IF (@ValidateFilter = 3)
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY

            IF OBJECT_ID('tempdb.dbo.#Sender', 'U') IS NOT NULL
                DROP TABLE #Sender;



  CREATE TABLE #Sender
            (
                [Sender_ID] INT,
                [SenderName] NVARCHAR(300),
                [Sender_Phone] NVARCHAR(100),
                [Hub] NVARCHAR(20),
                AmountPickup DECIMAL(12, 2),
                AddressPickup NVARCHAR(500),
                Number INT,
                Serie NVARCHAR(2),
                SchedulePickupId INT,
                AssigmentStatus INT,
                IdServiceManagement INT
            );
            CREATE NONCLUSTERED INDEX Senderserie ON #Sender (Serie, Number);
            CREATE NONCLUSTERED INDEX SchedulePickupIdtempGuide ON #Sender (SchedulePickupId);
            CREATE NONCLUSTERED INDEX IdServiceManagementtrempGuide ON #Sender (IdServiceManagement);

			INSERT INTO #Sender
			(
			    Sender_ID,
			    SenderName,
			    Sender_Phone,
			    Hub,
			    AmountPickup,
			    AddressPickup,
			    Number,
			    Serie,
			    SchedulePickupId,
			    AssigmentStatus,
			    IdServiceManagement
			)
            SELECT sub_do.[Sender_ID],
                   sub_do.[SenderName],
                   [Sender_Phone],
                   [Hub],
                   sub_do.AmountPickup,
                   sub_do.AddressPickup,
                   Number,
                   Serie,
                   sub_sp.SchedulePickupId,
                   sub_sp.AssigmentStatus,
                   sub_sp.IdServiceManagement
            FROM
            (
                SELECT Sender_ID,
                       CONCAT(Sender_FirstName, Sender_LastName) AS SenderName,
                       ord.Guide_Number AS Number,
                       ord.Guide_Serie AS Serie,
                       Sender_Phone,
                       HL.IdHublogistic AS Hub,
                       (SUM(dop.PaymentRecollections) + SUM(dop.RecolectPayment)) AS AmountPickup,
                       Sender_Address AS AddressPickup,
                       TypeService,
					   ord.IdCustomer
                FROM DeliveryOrder ord WITH(NOLOCK)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
						ON
							ord.SenderIdTownship = Twn.IdTownship
                    INNER JOIN (
						SELECT
							DSC.HeaderCode
							,MAX(DSC.Hub) 'hub'
						FROM
							[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
						GROUP BY
							DSC.HeaderCode
					) hubcov
                        ON (Twn.HeaderCode = hubcov.HeaderCode)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
						ON
							hubcov.hub = HL.HubAbbreviation COLLATE Latin1_General_CI_AI
                    INNER JOIN DeliveryOrderPaymentDetail dop
                        ON (
                               dop.GuideNumber = ord.Guide_Number
                               AND dop.GuideSerie = ord.Guide_Serie
                           )
                    INNER JOIN @TblDeliveryOrdersList t
                        ON (
                               t.Guide_Number = dop.GuideNumber
                               AND t.Guide_Serie = dop.GuideSerie
                           )
                WHERE ord.Guide_Number IN ( t.Guide_Number )
                GROUP BY Sender_ID,
						 IdCustomer,
                         Sender_Phone,
                         ord.Guide_Number,
                         ord.Guide_Serie,
                         HL.IdHublogistic,
                         Sender_Address,
                         Sender_FirstName,
                         Sender_LastName,
                         TypeService
            ) AS sub_do
                LEFT JOIN
                (		
                    SELECT DOR.Sender_ID,
                           AddressPickup,
                           SchedulePickupId,
                           SP.AssigmentStatus,
                           SM.IdServiceManagement,
						   DOR.IdCustomer
                    FROM dbo.SchedulePickup SP
                        LEFT JOIN dbo.ServiceManagement SM
                            ON SM.IdSchedulePickup = SP.SchedulePickupId
                        LEFT JOIN dbo.DeliveryOrderPaymentDetail dop
                            ON dop.IdHeaderRecolection = SP.SchedulePickupId
                        LEFT JOIN dbo.DeliveryOrder DOR WITH (NOLOCK)
                            ON DOR.Guide_Number = dop.GuideNumber
                               AND DOR.Guide_Serie = dop.GuideSerie
                    WHERE (
                              SM.IdServiceManagement IS NULL
                              OR
                              (
                                  SM.ServiceStatusId IN ( 1, 2 )
                                  AND SM.RowStatus = 1
                              )
                          )
                          AND
                          (
                              SP.SchedulePickupStatus IS NULL
                              OR SP.SchedulePickupStatus = 1
                          )
                          AND SP.RowStatus = 1
                          AND CONVERT(DATE, SP.StartDate) = CONVERT(DATE, @StartDate)
                    GROUP BY DOR.Sender_ID,
                             AddressPickup,
                             SchedulePickupId,
                             SP.AssigmentStatus,
                             SM.IdServiceManagement,
							 DOR.IdCustomer
                ) sub_sp
                    ON (
                           sub_do.Sender_ID = sub_sp.Sender_ID
                           AND sub_do.Sender_ID > 0
                       )
                       OR
                       (
                           sub_do.AddressPickup = sub_sp.AddressPickup
                           AND
                           (
                               sub_do.Sender_ID <= 0
                               OR sub_do.Sender_ID IS NULL
                           )
						   AND
                           sub_do.IdCustomer = sub_sp.IdCustomer
                       )
					   ;

            INSERT INTO dbo.SchedulePickup
            (
                AccountId,
                StartDate,
                EndDate,
                EstimatedWeight,
                IsLargePackage,
                QuantityRegularPackages,
                QuantityOverDimensionedPackage,
                SpecialInstructions,
                RowStatus,
                TokenCreated,
                DateCreated,
                TokenUpdated,
                DateUpdated,
                SenderId,
                SenderName,
                SenderPhone,
                IdHubLogistics,
                AmountPickup,
                IdSourcePlataform,
                AddressPickup,
                TypeVehicleId
            )
            SELECT @IdAccount,
                   @StartDate,
                   @EndDate,
                   @WeightEstimated,
                   @BigPackages,
                   @Regularpiezer,
                   @PartDimensions,
                   @InstructionsCurrier,
                   1,
                   @Token,
                   GETDATE(),
                   NULL,
                   NULL,
                   sd.Sender_ID,
                   MAX(sd.SenderName),
                   MAX(sd.Sender_Phone),
                   MAX(sd.Hub),
                   NULL,
                   NULL,
                   sd.AddressPickup,
                   @TypeVehicleId
            FROM #Sender sd
            WHERE sd.SchedulePickupId IS NULL
            GROUP BY sd.Sender_ID,
                     sd.AddressPickup;

            DECLARE @transaction INT = SCOPE_IDENTITY();

            --ACTUALIZANDO VEHÍCULO
            UPDATE sp
            SET sp.TypeVehicleId = @TypeVehicleId
            FROM SchedulePickup sp
            WHERE sp.SenderId IN
                  (
                      SELECT Sender_ID
                      FROM #Sender
                      WHERE SchedulePickupId IS NOT NULL
                      GROUP BY Sender_ID
                  );


            --ACTUALIZANDO GUIAS SIN SCHEDULE PICKUP 
            UPDATE dbo.DeliveryOrderPaymentDetail
            SET IdHeaderRecolection = @transaction,
                StartDate = @StartDate,
                EndDate = @EndDate,
                DateUpdated = GETDATE(),
                TokenUpdated = @Token
            FROM dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
                INNER JOIN @TblDeliveryOrdersList t
                    ON (
                           t.Guide_Number = pay.GuideNumber
                           AND t.Guide_Serie = pay.GuideSerie
                       )
                LEFT JOIN #Sender sd
                    ON sd.Serie = pay.GuideSerie
                       AND sd.Number = pay.GuideNumber
            WHERE sd.SchedulePickupId IS NULL;

            --ACTUALIZANDO GUIAS CONSCHEDULEPICKUP
            UPDATE dbo.DeliveryOrderPaymentDetail
            SET IdHeaderRecolection = sd.SchedulePickupId,
                StartDate = @StartDate,
                EndDate = @EndDate,
                DateUpdated = GETDATE(),
                TokenUpdated = @Token
            FROM dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
                INNER JOIN @TblDeliveryOrdersList t
                    ON (
                           t.Guide_Number = pay.GuideNumber
                           AND t.Guide_Serie = pay.GuideSerie
                       )
                LEFT JOIN #Sender sd
                    ON sd.Serie = pay.GuideSerie
                       AND sd.Number = pay.GuideNumber
            WHERE sd.SchedulePickupId IS NOT NULL;

            --ACTUALIZANDO MONTO DE SERVICIOS QUE YA ESTABAN ASIGNADOS A RUTA(SE SUMA EL NUEVO MONTO DE LA NUEVA GUÍA PROGRAMADO)
            DECLARE @TempPrice TABLE
            (
                GuideSerie NVARCHAR(25) NULL,
                GuideNumber NVARCHAR(25) NULL,
                IsCollect NVARCHAR(25) NULL,
                Price DECIMAL(14, 2) NULL,
                COD DECIMAL(14, 2) NULL,
                AmountPaid DECIMAL(14, 2) NULL,
                CODPaid DECIMAL(14, 2) NULL,
                CODIsPaid DECIMAL(14, 2) NULL,
                PaymentTime INT NULL,
                TimeSequence INT NULL,
                FelNumber NVARCHAR(50) NULL,
                IsPaid INT NULL,
                IsCustomer INT NULL,
                ConditionPayment NVARCHAR(200) NULL,
                HaveCredit NVARCHAR(50) NULL,
                CollectCOD NVARCHAR(50) NULL,
                ReturnRate DECIMAL(14, 2) NULL,
                AmountToPay DECIMAL(14, 2) NULL,
                CODAmount DECIMAL(14, 2) NULL,
                ReturnRates DECIMAL(14, 2) NULL
            );
            DECLARE @guides NVARCHAR(MAX) =
                    (
                        SELECT STUFF(
                               (
                                   SELECT DISTINCT
                                          ',' + CONCAT(Serie, Number)
                                   FROM #Sender
                                   GROUP BY Serie,
                                            Number
                                   FOR XML PATH('')
                               ),
                               1,
                               1,
                               ''
                                    )
                    );
            INSERT INTO @TempPrice
            (
                GuideSerie,
                GuideNumber,
                IsCollect,
                Price,
                COD,
                AmountPaid,
                CODPaid,
                CODIsPaid,
                PaymentTime,
                TimeSequence,
                FelNumber,
                IsPaid,
                IsCustomer,
                ConditionPayment,
                HaveCredit,
                CollectCOD,
                ReturnRate,
                AmountToPay,
                CODAmount,
                ReturnRates
            )
            EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @guides,
                                                        @InTime = 2,
                                                        @IsReturn = 'FALSE',
                                                        @CodeApp = 'SIFDCECOM300720201459',
                                                        @IdModule = 1,
                                                        @Token = 'SYSTEM';
            UPDATE SMT
            SET Amount = SUB.NewTotal
            FROM dbo.ServiceManagement SMT
                INNER JOIN
                (
                    SELECT SM.IdServiceManagement,
                           SM.Amount + SUM(TP.AmountToPay) AS NewTotal
                    FROM dbo.ServiceManagement SM
                        INNER JOIN dbo.#Sender SD
                            ON SM.IdServiceManagement = SD.IdServiceManagement
                        INNER JOIN @TempPrice TP
                            ON TP.GuideSerie = SD.Serie
                               AND TP.GuideNumber = SD.Number
                    GROUP BY SM.IdServiceManagement,
                             SM.Amount
                ) SUB
                    ON SMT.IdServiceManagement = SUB.IdServiceManagement;

			
			-- Actualizar
			update 
				do 
			set  
				StatusOrderId = 1 
			from 
				@TblDeliveryOrdersList ls
				inner join DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
				on 
					do.Guide_Serie =  ls.Guide_Serie 
					and 
					do.Guide_Number = ls.Guide_Number

			update 
				dopd 
			set 
				ShipmentCompleted = 1
			from 
				@TblDeliveryOrdersList ls
				inner join 
					DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd WITH(NOLOCK)
					on 
						dopd.GuideSerie =  ls.Guide_Serie 
						and 
						dopd.GuideNumber = ls.Guide_Number

			---	 insertar checkpoint de Solicitado, siempre que no exista y sea posible
			insert into DeliveryBackOffice.dbo.DeliveryOrderDetail ( 
				[Guide_Serie]
				,[Guide_Number]
				,[StatusOrderId]
				,[UserCreated]
				,[DateCreated]
				,[DateCreatedInSystem]
				,[Observations]
				,[Temperature_Celsius]
			)
			select 
				DISTINCT
					ls.Guide_Serie
					,ls.Guide_Number
					,1
					,@Token
					,GETDATE()
					,GETDATE()
					,null
					,null
			from 
				@TblDeliveryOrdersList ls
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
					ON
						ls.Guide_Serie = DOD.Guide_Serie
						AND
						ls.Guide_Number = DOD.Guide_Number
						AND
						DOD.StatusOrderId IN (1,21)
						AND
						DOD.RowStatus = 1
			WHERE
				DOD.DateCreated IS NULL

            DROP TABLE #Sender;

        END TRY
        BEGIN CATCH
            DECLARE @jsonOutput4 NVARCHAR(MAX);
            SET @jsonOutput4 =
            (
                SELECT ''
                       + STUFF(
                                  (
                                      SELECT ',{"Status":"' + ERROR_MESSAGE() + '"}' FOR XML PATH(''), TYPE
                                  ).value('.', 'varchar(max)'),
                                  1,
                                  1,
                                  ''
                              ) + ''
            );

            SELECT ('[' + @jsonOutput4 + ']') jsonOutput4;
            ROLLBACK TRANSACTION;

        END CATCH;

        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;

            DECLARE @jsonOutput5 NVARCHAR(MAX);
            SET @jsonOutput5 =
            (
                SELECT '' + STUFF(
                                     (
                                         SELECT ',{"Status":"Agrupación realizada exitosamente"}'
                                         FOR XML PATH(''), TYPE
                                     ).value('.', 'varchar(max)'),
                                     1,
                                     1,
                                     ''
                                 ) + ''
            );

            SELECT ('[' + @jsonOutput5 + ']') jsonOutput5;
        END;

    END;

    IF (@ValidateFilter = 4)
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY

            UPDATE dbo.DeliveryOrderPaymentDetail
            SET ShipmentCompleted = t.ShipmentCompleted,
                RecollectionCompleted = t.RecollectionCompleted,
                PaidGuide = t.PaidGuide
            FROM dbo.DeliveryOrderPaymentDetail pay
                INNER JOIN @TblDeliveryOrdersList t
                    ON (
                           t.Guide_Number = pay.GuideNumber
                           AND t.Guide_Serie = pay.GuideSerie
                       );

        END TRY
        BEGIN CATCH
            DECLARE @jsonOutput6 NVARCHAR(MAX);
            SET @jsonOutput =
            (
                SELECT ''
                       + STUFF(
                                  (
                                      SELECT ',{"Status":"' + ERROR_MESSAGE() + '"}' FOR XML PATH(''), TYPE
                                  ).value('.', 'varchar(max)'),
                                  1,
                                  1,
                                  ''
                              ) + ''
            );

            SELECT ('[' + @jsonOutput2 + ']') jsonOutput2;
            ROLLBACK TRANSACTION;

        END CATCH;

        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;

            DECLARE @jsonOutput7 NVARCHAR(MAX);
            SET @jsonOutput7 =
            (
                SELECT '' + STUFF(
                                     (
                                         SELECT ',{"Status":"Cambios actualizados exitosamente"}'
                                         FOR XML PATH(''), TYPE
                                     ).value('.', 'varchar(max)'),
                                     1,
                                     1,
                                     ''
                                 ) + ''
            );

            SELECT ('[' + @jsonOutput5 + ']') jsonOutput5;
        END;

    END;

    IF (@ValidateFilter = 5)
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY

            DECLARE @jsonResult NVARCHAR(MAX);

            UPDATE dbo.DeliveryOrder
            SET StatusOrderId = @IdStatus,
                IsCollect = t.IsCollect
            FROM dbo.DeliveryOrder ord with (nolock)
                INNER JOIN @TblDeliveryOrdersList t
                    ON t.Guide_Number = ord.Guide_Number
                       AND t.Guide_Serie = ord.Guide_Serie;

            DECLARE @IdAcc INT = @IdAccount;
            IF (@IdUser != 0)
            BEGIN
                SET @IdAcc =
                (
                    SELECT AccIdAccount
                    FROM dbo.InternalUser IU
                        INNER JOIN RegisterUser RU
                            ON RU.UsrIdUser = IU.RegisterUserID
                        INNER JOIN RolByUserByAccount RB
                            ON RB.RuaIdUser = RU.UsrIdUser
                        INNER JOIN Account ACC
                            ON RB.RuaIdAccount = ACC.AccIdAccount
                    WHERE IdUser = @IdUser
                );
            END;

            -- MODIFICACIÓN 07/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
            DECLARE @VistitPointUser1 INT =
                    (
                        SELECT CodeOfReference
                        FROM DeliveryBackOffice.dbo.VisitPointClient VPC
                            INNER JOIN VisitPointByUser VPU
                                ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
                                   AND VPU.RowStatus = 1
                            INNER JOIN RegisterUser ru
                                ON VPU.RegisterUserID = ru.UsrIdUser
                                   AND ru.UsrRowStatus = 1
                            INNER JOIN [dbo].[RolByUserByAccount] rua
                                ON rua.RuaIdUser = ru.UsrIdUser
                        WHERE rua.RuaIdAccount = @IdAccount
                    );
            -- FIN MODIFICACIÓN

            INSERT INTO dbo.DeliveryOrderPaymentTransaction
            (
                [GuideNumber],
                [GuideSerie],
                [PayTypeId],
                [TypeofInOutMoneyId],
                [TimePlaId],
                [amount],
                [PaymentRecollections],
                [PaymentNow],
                [PaymentDelivery],
                [StartDate],
                [EndDate],
                [ShipmentCompleted],
                [RecollectionCompleted],
                [PaidGuide],
                [TokenCreated],
                [DateCreated],
                [TokenUpdated],
                [DateUpdated],
                [TransaccionFAC],
                [IdHeaderRecolection],
                [TypeServiceId],
                [AccountId],
                [CODAmountProcess],
                -- MODIFICACIÓN 07/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                [VisitPoint]
            -- FIN MODIFICACIÓN
            )
            SELECT Guide_Number,
                   Guide_Serie,
                   IdTypePayment,
                   IdWayToPayment,
                   IdTimePayment,
                   tdop.PriceShippment,
                   tdop.PaymentRecollections,
                   tdop.PaymentNow,
                   tdop.PaymentDelivery,
                   NULL,
                   NULL,
                   tdop.ShipmentCompleted,
                   tdop.RecollectionCompleted,
                   tdop.PaidGuide,
                   @Token,
                   GETDATE(),
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   tdop.IdTypeService,
                   @IdAcc,
                   tdop.CODAmountProccess,
                   -- MODIFICACIÓN 07/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                   IIF(@VistitPointUser1 = 0, NULL, @VistitPointUser1)
            -- FIN MODIFICACIÓN
            FROM @TblDeliveryOrdersList tdop
            WHERE tdop.PriceShippment != 0
                  OR tdop.CODAmountProccess != 0;

        END TRY
        BEGIN CATCH
            DECLARE @jsonOut NVARCHAR(MAX);
            SET @jsonOut =
            (
                SELECT ''
                       + STUFF(
                                  (
                                      SELECT ',{"Status":"' + ERROR_MESSAGE() + '"}' FOR XML PATH(''), TYPE
                                  ).value('.', 'varchar(max)'),
                                  1,
                                  1,
                                  ''
                              ) + ''
            );

            SELECT ('[' + @jsonOut + ']') jsonOut;
            ROLLBACK TRANSACTION;

        END CATCH;

        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;

            DECLARE @jsonOut1 NVARCHAR(MAX);
            SET @jsonOut1 =
            (
                SELECT '' + STUFF(
                                     (
                                         SELECT ',{"Status":"Cambios realizados exitosamente"}'
                                         FOR XML PATH(''), TYPE
                                     ).value('.', 'varchar(max)'),
                                     1,
                                     1,
                                     ''
                                 ) + ''
            );

            SELECT ('[' + @jsonOut1 + ']') jsonOut1;
        END;

    END;
END;
