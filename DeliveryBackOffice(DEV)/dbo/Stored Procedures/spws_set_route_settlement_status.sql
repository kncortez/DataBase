
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-04>
-- Description:	<Cambia de estado de recolectado a ingreso a instalaciones>
-- =============================================

CREATE PROCEDURE [dbo].[spws_set_route_settlement_status]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @GuidePiece SMALLINT,
    @Token NVARCHAR(100),
    @Route VARCHAR(100),
    @CountryId VARCHAR(2)
AS
BEGIN

    DECLARE @RModified INT = 0;
    DECLARE @RModified2 INT = 0;
    DECLARE @RModified3 INT = 0;

    DECLARE @GModif INT = 0;

    DECLARE @Description NVARCHAR(2048);

    DECLARE @IsDry BIT;

    BEGIN TRANSACTION;
    BEGIN TRY


        DECLARE @stattus INT = 11;

        /* Inserción en tabla TransactionalBackbone para guardar 
			un registro de las piezas que se estan liquidando de una ruta										 
		 */

        DECLARE @inBound INT =
                (
                    SELECT IdTranportationZone
                    FROM DeliveryBackOffice.dbo.CatTransportationZone
                    WHERE Name = 'Ruta de recolección'
                );

        DECLARE @outBound INT =
                (
                    SELECT IdTranportationZone
                    FROM DeliveryBackOffice.dbo.CatTransportationZone
                    WHERE Name = 'Bodega'
                );

        DECLARE @idTransactionType INT =
                (
                    SELECT IdTransactionType
                    FROM DeliveryBackOffice.dbo.TransactionType
                    WHERE Name = 'Liquidación de Recolección'
                );

        DECLARE @IdRoute INT =
                (
                    SELECT IdRoute
                    FROM DeliveryBackOffice.dbo.CatRoute
                    WHERE CodeRoute = @Route
                );

        INSERT INTO DeliveryBackOffice.dbo.TransactionalBackbone
        (
            GuideSerie,
            GuideNumber,
            GuidePiece,
            RouteId,
            InBound,
            OutBound,
            LineHaul,
            StatusComplete,
            TransactionTypeId,
            CountryId,
            RowStatus,
            TokenCreated,
            DateCreated
        )
        SELECT DISTINCT
               @GuideSerie,
               @GuideNumber,
               @GuidePiece,
               @IdRoute,
               @inBound,
               @outBound,
               0,
               0,
               @idTransactionType,
               @CountryId,
               1,
               @Token,
               GETDATE()
        FROM DeliveryOrderPiece ord
        --LEFT JOIN DeliveryOrderPaymentDetail dopd
        --    ON dopd.GuideSerie = @GuideSerie
        --       AND dopd.GuideNumber = @GuideNumber
        --LEFT JOIN ServiceManagement sm
        --    ON sm.IdSchedulePickup = dopd.IdHeaderRecolection
        --LEFT JOIN RouteAssigment ra
        --    ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
        --AND ra.IdRoute = @IdRoute
        WHERE (
                  ord.GuideNumber = @GuideNumber
                  AND ord.GuideSerie = @GuideSerie
                  AND ord.NoPiece = @GuidePiece
                  AND
                  (
                      ord.StatusOrderId NOT IN ( 7, 11, 5, 4, 12, 18) --Se agrega en ruta e intento de entrega fallida
                      OR ord.StatusOrderId IS NULL
                  )
              );
        --AND --YA NO APLICA PORQUE EN LIQUIDACIÓN DE RECOLECCIÓN SE PUEDE LIQUIDAR GUÍAS QUE NO TIENEN
        --ASOCIADAS RECOLECCIONES
        --(
        --    dopd.DopId IS NULL -- No tiene asociada una solicitud de recolección, Ej. generada
        --    OR
        --    (
        --        dopd.DopId IS NOT NULL -- tiene una solicitud de recolección
        --        --AND ra.IdRouteAssigment IS NOT NULL --pero no tiene ruta asignada
        --    )
        --    OR dopd.IdHeaderRecolection IS NULL -- la guía se generó pero no se solicitó recolección
        --);

        SET @RModified3 = @@rowcount;

        IF @RModified3 > 0
        BEGIN
            UPDATE dbo.DeliveryOrderPiece
            SET StatusOrderId = @stattus,
                @IsDry = ISNULL(ord.IsDry, 1)
            FROM dbo.DeliveryOrderPiece ord
            WHERE (
                      ord.GuideNumber = @GuideNumber
                      AND ord.GuideSerie = @GuideSerie
                      AND ord.NoPiece = @GuidePiece
					  --Se comenta porque es la misma validación que se hace anteriormente
                      --AND
                      --(
                      --    ord.StatusOrderId NOT IN ( 7, 11, 5 )
                      --    OR ord.StatusOrderId IS NULL
                      --)
                  );
            --inner join dbo.DeliveryOrderPaymentDetail dop on (ord.GuideNumber = dop.GuideNumber and ord.GuideSerie = dop.GuideSerie and  (ord.StatusOrderId = 15 and dop.ShipmentCompleted = 1))

            SET @RModified = @@rowcount;
        END;
        --end
        --else
        --begin 
        --		update  dbo.DeliveryOrderPiece set StatusOrderId =  @stattus
        --		from dbo.DeliveryOrderPiece ord
        --		 inner join #listGuides ls on (ord.GuideNumber = ls.ItemNumber and ord.GuideSerie = ls.ItemSerie)
        --end
        ---variable que cuenta cuantas piezas estan asociadas a las guias.
        DECLARE @val INT =
                (
                    SELECT COUNT(1)
                    FROM DeliveryOrderPiece
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                );
        ---variable que cuenta cuantas piezas ya cambiaron de estado arribo a instalaciones (11).
        DECLARE @valu INT =
                (
                    SELECT COUNT(1)
                    FROM DeliveryOrderPiece
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                          AND StatusOrderId = @stattus
                );

        --declare @value int = (select count (GuideNumber) from DeliveryOrderPiece where GuideNumber in (select ItemNumber from #listGuides))

		---	 insertar checkpoint de recolectado.	
        INSERT INTO dbo.DeliveryOrderDetail
        (
            [Guide_Serie],
            [Guide_Number],
            [StatusOrderId],
            [UserCreated],
            [DateCreated],
            [DateCreatedInSystem],
            [Observations],
            [Temperature_Celsius],
            [PieceId]
        )
        VALUES
        (@GuideSerie, @GuideNumber, 2, @Token, GETDATE(), GETDATE(), NULL, NULL, @GuidePiece);

        ---	 insertar checkpoint de arribo a instalaciones.	
        INSERT INTO dbo.DeliveryOrderDetail
        (
            [Guide_Serie],
            [Guide_Number],
            [StatusOrderId],
            [UserCreated],
            [DateCreated],
            [DateCreatedInSystem],
            [Observations],
            [Temperature_Celsius],
            [PieceId]
        )
        VALUES
        (@GuideSerie, @GuideNumber, @stattus, @Token, GETDATE(), GETDATE(), NULL, NULL, @GuidePiece);

        SET @RModified2 = @@rowcount;

        IF (@val = @valu)
        BEGIN
            UPDATE do
            SET do.StatusOrderId = @stattus
            FROM DeliveryOrder do
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber;
            SET @GModif = @@rowcount;

        -- Activar bandera de proceso de SMS
        -- Se comenta porque no está en uso
        IF (@stattus = 11) --En ruta, (11) Arribó a instalaciones
        	IF ((SELECT TOP 1
        				ue.UpdateStatus
        			FROM [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue
        			WHERE ue.RowStatus = 1
        			AND ue.ElementId = 1001)
        		= 0)
        	BEGIN
        		UPDATE [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
        		SET UpdateStatus = 1
        		   ,UpdateDateTime = GETDATE()
        		WHERE RowStatus = 1
        		AND ElementId = 1001
        	END

        END;

		--Se marca como recolectado el servicio
		UPDATE sm
		SET ServiceStatusId = 3
			,TokenUpdated = @Token
			,DateUpdated = GETDATE()
		FROM ServiceManagement sm
		INNER JOIN DeliveryOrderPaymentDetail dopd
			ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
		WHERE
			dopd.GuideSerie = @GuideSerie AND dopd.GuideNumber = @GuideNumber
		
		--Validar si pertenece a un punto de visita
		DECLARE @tiempo DATE = (SELECT
			CAST(GETDATE() AS DATE))
		DECLARE @Sender_ID INT
		DECLARE @SchedulePickupId BIGINT
		DECLARE @dopdId BIGINT 
		DECLARE @ServiceManagementId INT
		DECLARE @ServiceManagementIdFind INT
		DECLARE @SchedulePickupIdFind BIGINT
		DECLARE @RouteAssigment INT
		DECLARE @RouteAssigmentFind INT
		DECLARE @FindServiceManagement BIT = 0
		DECLARE @CreateServiceManagement BIT = 0
		DECLARE @ServiceStatus INT =( SELECT
				IdServiceStatus
			FROM CatServiceStatus
			WHERE [Name] = 'Recolectado')

		--Validar que tenga registro en la DeliveryOrderPaymentDetail sino lo crea
		SELECT
			@dopdId = dopd.DopId
		   ,@SchedulePickupId = dopd.IdHeaderRecolection
		FROM DeliveryOrderPaymentDetail dopd
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
			, [RecolectPayment]
			--,[TypeService]
			--,[IdAccount]
			)
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
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				--,NULL
				--,NULL
				FROM DeliveryOrder do
				INNER JOIN Customer cu
					ON cu.IdCustomer = (SELECT TOP 1
								ISNULL(do.IdCustomer, vpc.CustomerID)
							FROM dbo.VisitPointClient vpc
							WHERE vpc.CodeOfReference = do.Sender_ID)
				WHERE do.Guide_Serie = @GuideSerie
				AND do.Guide_Number = @GuideNumber

			SET @dopdId = SCOPE_IDENTITY()
		END

		--Validar si pertenece a un punto de visita para buscar si ya existe el servicio
		SELECT
			@Sender_ID = do.Sender_ID
		FROM DeliveryOrder do WITH (NOLOCK)
		WHERE do.Guide_Serie = @GuideSerie
		AND do.Guide_Number = @GuideNumber

		--Si tine vp asignado 
		IF @Sender_ID IS NOT NULL AND @Sender_ID <> 0
		BEGIN
			--Si tiene un SchedulePickup buscar si ya está asignado a un servicio y si es el correcto
			IF @SchedulePickupId IS NOT NULL
			BEGIN 

				UPDATE SchedulePickup
				SET AssigmentStatus = 1
				WHERE SchedulePickupId = @SchedulePickupId

				--Buscar si tiene asignado un servicio
				SELECT 
					@ServiceManagementId = sm.IdServiceManagement
				FROM ServiceManagement sm
				WHERE sm.IdSchedulePickup = @SchedulePickupId

				--Si encontró el servicio
				IF @ServiceManagementId IS NOT NULL
				BEGIN

					--Válidar que este asignado a la ruta
					IF EXISTS (SELECT
							1
						FROM RouteAssigment ra
						INNER JOIN ServiceManagement sm
							ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
							AND sm.IdServiceManagement = @ServiceManagementId
						WHERE ra.IdRoute = @IdRoute
						AND ra.DateOfRoute = @tiempo)
					BEGIN
						--Se marca como recolectado
						UPDATE sm
						SET ServiceStatusId = 3
						FROM ServiceManagement sm
						WHERE
							sm.IdServiceManagement = @ServiceManagementId

						--Insertar EventService si no existe
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
								VALUES (@ServiceManagementId, @ServiceStatus, 1, @Token, GETDATE(), NULL)
						END

					END
					ELSE
					BEGIN
						SET @FindServiceManagement = 1
					END
				END
				ELSE
				BEGIN
					SET @FindServiceManagement = 1
				END
			END
			ELSE
			BEGIN
				SET @FindServiceManagement = 1
			END
			
			--Si se tiene que buscar si un servicio si coincide con el vp
			IF @FindServiceManagement = 1
			BEGIN

				SELECT
					@SchedulePickupIdFind = sm.IdSchedulePickup
					,@ServiceManagementIdFind = sm.IdServiceManagement
				FROM RouteAssigment ra
				INNER JOIN ServiceManagement sm
					ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
				INNER JOIN SchedulePickup sp
					ON sp.SchedulePickupId = sm.IdSchedulePickup
				WHERE ra.IdRoute= @IdRoute
				AND ra.DateOfRoute = @tiempo
				AND sp.SenderId = @Sender_ID
				
				--Si se encuentra el vp entre los servicios de recolección, se asigna
				IF @SchedulePickupIdFind IS NOT NULL
				BEGIN
					UPDATE DeliveryOrderPaymentDetail 
					SET IdHeaderRecolection = @SchedulePickupIdFind
					WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber

					--Se marca como recolectado
					UPDATE sm
					SET ServiceStatusId = 3
					FROM ServiceManagement sm
					WHERE
						sm.IdSchedulePickup = @SchedulePickupIdFind

					UPDATE SchedulePickup
					SET AssigmentStatus = 1
					WHERE SchedulePickupId = @SchedulePickupIdFind

					--Insertar EventService si no existe
					IF NOT EXISTS (SELECT
							1
						FROM EventService es
						WHERE es.ServiceManagementId = @ServiceManagementIdFind
						AND es.ServiceStatusId = @ServiceStatus
						AND es.RowStauts = 1)
					BEGIN
						INSERT INTO EventService (ServiceManagementId,
						ServiceStatusId,
						RowStauts,
						TokenCreated,
						DateCreated,
						Observations)
							VALUES (@ServiceManagementIdFind, @ServiceStatus, 1, @Token, GETDATE(), NULL)
					END
				END
				ELSE
				BEGIN
					SET @CreateServiceManagement = 1
				END
			END
		END
		ELSE
		BEGIN
			SET @CreateServiceManagement = 1
		END

		--Si se tiene que crear el servicio
		IF @CreateServiceManagement = 1
		BEGIN
			-- Si no tiene un SchedulePicku, lo crea y lo asigna
			IF @SchedulePickupId IS NULL
			BEGIN 
						
				INSERT INTO [dbo].[SchedulePickup] ([AccountId]
				, [StartDate]
				, [EndDate]
				, [EstimatedWeight]
				, [IsLargePackage]
				, [QuantityRegularPackages]
				, [QuantityOverDimensionedPackage]
				, [SpecialInstructions]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated]
				, [TokenUpdated]
				, [DateUpdated]
				, [SenderId]
				, [SenderName]
				, [SenderPhone]
				, [IdHubLogistics]
				, [AmountPickup]
				, [IdSourcePlataform]
				, [AddressPickup]
				, [AssigmentStatus]
				, [TransaccionFAC]
				, [TownshipId])
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
						,CONCAT(ISNULL(do.Sender_FirstName, ''), IIF(do.Sender_FirstName IS NULL, '', IIF(do.Sender_LastName IS NULL, '', ' ')), ISNULL(do.Sender_LastName, ''))
						,do.Sender_Phone
						,NULL -- [IdHubLogistics]
						,NULL -- [AmountPickup]
						,2 -- [IdSourcePlataform]
						,do.Sender_Address
						,1
						,NULL --TransaccionFAC
						,NULL --TownshipId
					FROM DeliveryOrder do
					LEFT JOIN Account acc
						ON acc.IdCustomer = (SELECT TOP 1
									ISNULL(do.IdCustomer, vpc.CustomerID)
								FROM dbo.VisitPointClient vpc
								WHERE vpc.CodeOfReference = do.Sender_ID)
					WHERE do.Guide_Serie = @GuideSerie
					AND do.Guide_Number = @GuideNumber

				SET @SchedulePickupId = SCOPE_IDENTITY()

				UPDATE DeliveryOrderPaymentDetail 
				SET IdHeaderRecolection = @SchedulePickupId
				WHERE DopId = @dopdId
			END
			ELSE
			BEGIN
				UPDATE SchedulePickup
				SET AssigmentStatus = 1
				WHERE SchedulePickupId = @SchedulePickupId
			END

			--si ya tiene un servicio, solo lo reasigna
			IF @ServiceManagementId IS NOT NULL
			BEGIN
				UPDATE sm 
				SET
					sm.IdPuRouteAssigment = ra.IdRouteAssigment
				FROM ServiceManagement sm
				INNER JOIN RouteAssigment ra
					ON ra.IdRoute = @IdRoute
					AND ra.DateOfRoute = @tiempo
				WHERE sm.IdServiceManagement = @ServiceManagementId

				--Se marca como recolectado
				UPDATE sm
				SET ServiceStatusId = 3
				FROM ServiceManagement sm
				WHERE
					sm.IdServiceManagement = @ServiceManagementId

				--Insertar EventService si no existe
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
						VALUES (@ServiceManagementId, @ServiceStatus, 1, @Token, GETDATE(), NULL)
				END

			END
			ELSE
			BEGIN
				--Crea el servicio y lo asigna
				INSERT INTO [dbo].[ServiceManagement]
					   ([IdPuCourrier]
					   ,[IdDlCourrier]
					   ,[CiPuDate]
					   ,[CoPuDate]
					   ,[CiDlDate]
					   ,[CoDlDate]
					   ,[IdPuRouteAssigment]
					   ,[IdDlRouteAssigment]
					   ,[IdSchedulePickup]
					   ,[IdProofOnDelivery]
					   ,[RowStatus]
					   ,[TokenCreated]
					   ,[DateCreated]
					   ,[TokenUpdated]
					   ,[DateUpdated]
					   ,[ServiceStatusId]
					   ,[PuSignaturePath]
					   ,[DiSignaturePath]
					   ,[SubTypeServiceManagmentId]
					   ,[IdHubDestination]
					   ,[Order])
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
				FROM RouteAssigment ra
				WHERE ra.IdRoute = @IdRoute
				AND ra.DateOfRoute = @tiempo

				SET @ServiceManagementId = SCOPE_IDENTITY()

				--Insertar EventService si no existe
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
						VALUES (@ServiceManagementId, @ServiceStatus, 1, @Token, GETDATE(), NULL)
				END
			END
		END

    END TRY
    BEGIN CATCH
        IF EXISTS
        (
            SELECT 1
            FROM DeliveryOrder
            WHERE Guide_Serie = @GuideSerie
                  AND Guide_Number = @GuideNumber
        )
            SET @Description = CONCAT('Error: ', ERROR_MESSAGE());
        ELSE
            SET @Description = CONCAT('La guía ', @GuideSerie, @GuideNumber, ' no existe.');

        SELECT 0 AS 'StatusCode',
               @Description 'Description',
               --	CONVERT(BIGINT, 0) AS 'NumTransferID',
               CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide',
               0 AS 'SubStatusCode',
               0 'IsDry';
        ROLLBACK TRANSACTION;

        SELECT 'No se guardo el registro' AS StatusCode;
    --select ERROR_MESSAGE()
    -- retornar mensaje de error


    END CATCH;
    IF @@trancount > 0
    BEGIN

        IF (@RModified > 0 AND @RModified2 > 0)
        BEGIN

            SELECT 1 AS 'StatusCode'
				   ,@GuideSerie GuideSerie
				   ,@GuideNumber GuideNumber
				   ,@GuidePiece GuidePiece
                   ,@IsDry 'IsDry'
				   ,COALESCE(do.Pieces_Dry,0) + COALESCE(do.Pieces_Cold,0) Pieces
			FROM DeliveryOrder do WITH (NOLOCK)
			WHERE do.Guide_Serie = @GuideSerie
				AND do.Guide_Number = @GuideNumber


            SELECT @GModif AS CONT;

			SELECT
				(CASE
					WHEN do.Manifest_Serie IS NOT NULL AND
						do.Manifest_Number IS NOT NULL THEN CONCAT(do.Manifest_Serie, '-', do.Manifest_Number)
					ELSE ''
				END) MANIFIESTO
			   ,ISNULL(sp.SenderName, vpc.DescriptionOfClient) REMITENTE
			   ,ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0) PIECE
			   --,vpc.CodeOfReference CodeOfReference
			FROM RouteAssigment ra
			INNER JOIN ServiceManagement sm
				ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
			INNER JOIN SchedulePickup sp
				ON sp.SchedulePickupId = sm.IdSchedulePickup
			INNER JOIN VisitPointClient vpc
				ON vpc.CodeOfReference = sp.SenderId
			LEFT JOIN DeliveryOrderPaymentDetail dopd
				ON dopd.IdHeaderRecolection = sp.SchedulePickupId
			LEFT JOIN DeliveryOrder do
				ON do.Guide_Serie = dopd.GuideSerie
					AND do.Guide_Number = dopd.GuideNumber
			WHERE ra.IdRoute = @IdRoute
			AND ra.DateOfRoute = @tiempo

            COMMIT TRANSACTION;
        END;

        ELSE
        BEGIN
            IF @RModified3 = 0
            BEGIN
                DECLARE @Status NVARCHAR(100);

                SELECT @Status = so.OrderDescription
                FROM DeliveryOrderPiece do
                    INNER JOIN StatusOrder so
                        ON so.StatusOrderId = do.StatusOrderId
                WHERE do.GuideSerie = @GuideSerie
                      AND do.GuideNumber = @GuideNumber
                      AND do.NoPiece = @GuidePiece
                      AND do.StatusOrderId IN ( 7, 11, 5, 4, 12, 18);

                IF @Status IS NOT NULL
                    SET @Description = CONCAT('La pieza ', @GuideSerie, @GuideNumber, '-', @GuidePiece, ' se encuentra en estado: ',@Status,'.');
                ELSE IF EXISTS
                (
                    SELECT 1
                    FROM DeliveryOrderPiece
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                          AND NoPiece = @GuidePiece
                )
                    SET @Description = N'Error: INSERT INTO TransactionalBackbone.';
                ELSE
                    SET @Description = CONCAT('La pieza ', @GuideSerie, @GuideNumber, '-', @GuidePiece, ' no existe.');

            END;
            ELSE IF @RModified = 0
                SET @Description = N'Error: INSERT INTO DeliveryOrderPiece.';
            ELSE IF @RModified2 = 0
                SET @Description = N'Error: INSERT INTO DeliveryOrderDetail.';


            SELECT 0 AS 'StatusCode',
                   @Description AS 'Description',
                   --	0 AS 'NumTransferID',
                   CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide',

                   --@Amount AS 'Amount',
                   0 AS 'SubStatusCode',
                   0 'IsDry';
            ROLLBACK TRANSACTION;
        END;
    END;
END;