USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_set_route_settlement_status]    Script Date: 10/04/2026 10:26:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =================================================
   SP:        [dbo].[spws_set_route_settlement_status]
   Propósito: <Cambia de estado de recolectado a ingreso a instalaciones>
   Autor:     <Hugo, Gomez>
   Historia:  <>  
   Fecha:     2020-03-04

=== CHANGELOG ================================

--  2024-06-11 | Historia/épica: ---         | Autor: Daniel, Ramirez |
--  2025-11-20 | Historia/épica: FDAPI-4736  | Autor: Cristian, Suazo |
--  2026-04-10 | Historia/epica: FDAPI-5556  | Autor: Eduardo Gonzalez|

=========================================== */
ALTER PROCEDURE [dbo].[spws_set_route_settlement_status]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @GuidePiece SMALLINT,
    @Token NVARCHAR(100),
    @Route VARCHAR(100)=NULL,
    @CountryId VARCHAR(2) = 'GT',
    @StationId INT = NULL
AS
BEGIN

    DECLARE @RModified INT = 0;
    DECLARE @RModified2 INT = 0;
    DECLARE @RModified3 INT = 0,
            @SenderCountryId VARCHAR(2) = NULL;


    DECLARE @GModif INT = 0;

    DECLARE @Description NVARCHAR(2048);

    DECLARE @IsDry BIT;

	DECLARE @IsStatusTerminal int = (Select Count(Guide_Number) FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
                                                                INNER JOIN 
																     [DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK)
																	 ON DO.StatusOrderId = SO.StatusOrderId
																WHERE
																[CatCheckpointTypeId] = 3 And SO.RowStatus= 1
																And DO.Guide_Serie=@GuideSerie And Guide_Number = @GuideNumber
											)

	DECLARE @StatusDescription NVARCHAR(2048) = (SELECT SO.OrderDescription FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
	                                                INNER JOIN dbo.StatusOrder SO
														ON DO.StatusOrderId = SO.StatusOrderId
													WHERE DO.Guide_Serie=@GuideSerie And Guide_Number = @GuideNumber)


        IF EXISTS
        (
            SELECT TOP 1 1
              FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
             WHERE Guide_Serie = @GuideSerie
               AND Guide_Number = @GuideNumber
        )
        BEGIN
            SELECT @SenderCountryId = SenderCountryId
              FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
             WHERE Guide_Serie = @GuideSerie
               AND Guide_Number = @GuideNumber

            IF @SenderCountryId <> @CountryId
            BEGIN
                  SET @Description = CONCAT('La guía ', @GuideSerie, @GuideNumber, ' no existe.');

                  SELECT 0 AS 'StatusCode',
                         @Description 'Description',
                         CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide',
                         0 AS 'SubStatusCode',
                         0 'IsDry', 
                         @IsStatusTerminal 'IsTerminal'

                  SELECT 'No se guardo el registro' AS StatusCode;

                  RETURN;
            END
        END


	If( @IsStatusTerminal = 1)	
				Begin
					SET @Description ='*** Guía : '+ @GuideSerie + CONVERT(nvarchar(25),@GuideNumber) +' en estado Terminal : '+ @StatusDescription  +' ***';	

            SELECT 0 AS 'StatusCode',
                   @Description AS 'Description',
                   --	0 AS 'NumTransferID',
                   CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide', 

                   --@Amount AS 'Amount',
                   0 AS 'SubStatusCode',
                   0 'IsDry',
				   0 'IsTerminal'

				End 
   Else
   Begin

    BEGIN TRANSACTION;
    BEGIN TRY







        DECLARE @stattus INT = 11;

        /* Inserción en tabla TransactionalBackbone para guardar 
			un registro de las piezas que se estan liquidando de una ruta										 
		 */

        DECLARE @inBound INT = 1; -- CatTransportationZone -> 'Ruta de recolección'

        DECLARE @outBound INT =  4; -- CatTransportationZone -> 'Bodega'

        DECLARE @idTransactionType INT = 1; -- TransactionType -> 'Liquidación de Recolección'

        DECLARE @IdRoute INT = 0

        IF @Route IS NULL BEGIN
            SELECT TOP 1
            @IdRoute = cr.IdRoute,
            @Route = cr.CodeRoute
            FROM dbo.DeliveryOrderPaymentDetail  AS dop WITH (NOLOCK)
            INNER JOIN dbo.ServiceManagement AS sm WITH (NOLOCK) ON sm.IdSchedulePickup = dop.IdHeaderRecolection
            INNER JOIN dbo.RouteAssigment AS rs WITH (NOLOCK) ON rs.IdRouteAssigment = sm.IdPuRouteAssigment
            INNER JOIN dbo.CatRoute AS cr WITH (NOLOCK) ON cr.IdRoute = rs.IdRoute
            WHERE dop.GuideSerie = @GuideSerie AND dop.GuideNumber = @GuideNumber
        END
        ELSE BEGIN
            SELECT TOP 1 
            @IdRoute = IdRoute
            FROM DeliveryBackOffice.dbo.CatRoute WITH (NOLOCK)
            WHERE CodeRoute = @Route
            AND RowStatus = 1
        END
   
	 
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
        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece ord WITH (NOLOCK)
        WHERE (
                  ord.GuideSerie = @GuideSerie
                  AND ord.GuideNumber = @GuideNumber
                  AND ord.NoPiece = @GuidePiece
                  AND
                  (
                      ord.StatusOrderId NOT IN ( 7, 11, 5, 4, 12, 18 ) --Se agrega en ruta e intento de entrega fallida
                      OR ord.StatusOrderId IS NULL
                  )
              );
		

        SET @RModified3 = @@rowcount;
		
        IF (@RModified3 > 0 )
        BEGIN
            UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
            SET StatusOrderId = @stattus,
                @IsDry = ISNULL(ord.IsDry, 1)
            FROM DeliveryBackOffice.dbo.DeliveryOrderPiece ord WITH (NOLOCK)
            WHERE (
                      ord.GuideSerie = @GuideSerie
                      AND ord.GuideNumber = @GuideNumber
                      AND ord.NoPiece = @GuidePiece
                  );


            SET @RModified = @@rowcount;
        END;
        ---variable que cuenta cuantas piezas estan asociadas a las guias.
        DECLARE @val INT =
                (
                    SELECT COUNT(1)
                    FROM DeliveryBackOffice.dbo.DeliveryOrderPiece WITH (NOLOCK)
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                );
        ---variable que cuenta cuantas piezas ya cambiaron de estado arribo a instalaciones (11).
        DECLARE @valu INT =
                (
                    SELECT COUNT(1)
                    FROM DeliveryBackOffice.dbo.DeliveryOrderPiece WITH (NOLOCK)
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                          AND StatusOrderId = @stattus
                );


        ---	 insertar checkpoint de recolectado.	
		IF( 
			(
				SELECT 
					TOP 1 
						DO.StatusOrderId 
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) 
				WHERE 
					DO.Guide_Serie = @GuideSerie 
					AND 
					DO.Guide_Number = @GuideNumber
			) IN (1,15,16)  -- Solicitado, Generado, Programado para recolección
		)
		BEGIN
			INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
			(
				[Guide_Serie],
				[Guide_Number],
				[StatusOrderId],
				[UserCreated],
				[DateCreated],
				[DateCreatedInSystem],
				[Observations],
				[Temperature_Celsius],
				[PieceId],
				[StationId]
			)
			VALUES
			(@GuideSerie, @GuideNumber, 2, @Token, GETDATE(), GETDATE(), NULL, NULL, @GuidePiece, @StationId);

			-----------------WEBHOOK.INI RECOLECCION-----------------------		
						DECLARE @WebhookCustomerIdRec INT = -1;
						DECLARE @CustomerEndpointIdRec INT = -1;
						-- Debido a que se procesa únicamente 1 guía
						DECLARE @GuideCurrentStatusRec INT = -1;

						BEGIN TRY
							DECLARE @GuideStatusChangeWebhookRec INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' AND WT.RowStatus = 1);

							SET @WebhookCustomerIdRec = ISNULL((SELECT TOP 1 DO.IdCustomer FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber),-1);
							SET @CustomerEndpointIdRec = ISNULL((SELECT TOP 1 WE.IdWebhookEndpoint FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK) WHERE WE.CustomerId = @WebhookCustomerIdRec AND  WE.WebhookTypeId = @GuideStatusChangeWebhookRec),-1);

							SET @GuideCurrentStatusRec = 2

							-- Cliente tiene webhook configurado para el tipo especificado
							-- Estado actual de la guía coincide dentro de las restricciónes por usuario
							IF ( @WebhookCustomerIdRec > 0 AND @CustomerEndpointIdRec > 0 AND @GuideCurrentStatusRec IN (SELECT WRBU.StatusOrderId FROM [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK) WHERE WRBU.CustomerId = @WebhookCustomerIdRec AND WRBU.WebhookTypeId = @GuideStatusChangeWebhookRec) )
							BEGIN 

								DECLARE @ResponseTableRec AS TABLE (
									InsertedId BIGINT
								);

							
								DECLARE @TypeConnectRec INT = 0;

										SET @TypeConnectRec = (SELECT top 1 TypeConnectionId 
												FROM DeliveryBackOffice.dbo.WebhookEndpoint wh
												INNER JOIN DeliveryBackOffice.dbo.WebhookCatTypeConnection wc
													ON wh.TypeConnectionId = wc.IdCatTypeConnection
												WHERE wh.CustomerId = @WebhookCustomerIdRec)

							IF(@TypeConnectRec = 1)
								 BEGIN

										INSERT INTO 
											[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
											(
												[GuideSerie]
												,[GuideNumber]
												,[CustomerId]
												,[StatusOrderId]
												,[WebhookEndpointId]
												,[HasNotified]
												,[TokenCreated]
												,[DateCreated]
											)
										OUTPUT inserted.IdWebhookTrackingQueue INTO @ResponseTableRec (InsertedId)
										VALUES
											(
												@GuideSerie
												,@GuideNumber
												,@WebhookCustomerIdRec
												,@GuideCurrentStatusRec
												,@CustomerEndpointIdRec
												,0
												,@Token
												,GETDATE()
											)
								 END
							ELSE
								 BEGIN
										-----------------------------------
													 DECLARE @GuidePiecesTableRec AS TABLE
													(
													    CustomerId INT,
													    CustomerEndpointId BIGINT,
													    WebhookType INT,
													    GuideSerie NVARCHAR(2),
													    GuideNumber INT,
													    GuideStatusId TINYINT,
														NumberPieces INT,
														NumberRelatedPieces INT
														
													);

													INSERT INTO @GuidePiecesTableRec 
																( 
															CustomerId,
													        GuideSerie,
													        GuideNumber,
													        GuideStatusId,
															NumberPieces
															)
															SELECT @WebhookCustomerIdRec,
																	dop.GuideSerie,dop.GuideNumber, 
																	@GuideCurrentStatusRec,
																	Count(dop.GuideNumber)
															FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
															INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
																ON do.Guide_Serie = dop.GuideSerie
																AND do.Guide_Number = dop.GuideNumber
															INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
																ON do.IdCustomer = WHE.CustomerId
															WHERE do.Guide_Serie = @GuideSerie 
                                                                AND do.Guide_Number = @GuideNumber
																AND WHE.TypeConnectionId = 2
															GROUP BY dop.GuideSerie,dop.GuideNumber

													   DECLARE @PiecesGuideRelatedTableRec AS TABLE
													(
													    CustomerId INT,
													    CustomerEndpointId BIGINT,
													    WebhookType INT,
													    GuideSerie NVARCHAR(2),
													    GuideNumber INT,
													    GuideStatusId TINYINT,
														NumberRelatedPieces INT
														
													);

													DECLARE @MaxPieceOrderDetail INT = 0;
													SET @MaxPieceOrderDetail = IIF((SELECT MAX(PieceId) FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH(NOLOCK) Where Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND StatusOrderId = 2) IS NULL,0,(SELECT MAX(PieceId) FROM DeliveryBackOffice.dbo.DeliveryOrderDetail Where Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND StatusOrderId = 2))

													INSERT INTO @PiecesGuideRelatedTableRec 
																( 
															CustomerId,
													        GuideSerie,
													        GuideNumber,
													        GuideStatusId,
															NumberRelatedPieces
															)
															SELECT @WebhookCustomerIdRec,
																	dop.GuideSerie,dop.GuideNumber, 
																	@GuideCurrentStatusRec,
																	Count(dop.GuideNumber)
															FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
															INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
																ON do.Guide_Serie = dop.GuideSerie
																AND do.Guide_Number = dop.GuideNumber
															INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
																ON do.IdCustomer = WHE.CustomerId
															WHERE do.Guide_Serie = @GuideSerie
																AND do.Guide_Number = @GuideNumber
																AND dop.ExternalPieceId IS NOT NULL
																AND WHE.TypeConnectionId = 2
															GROUP BY dop.GuideSerie,dop.GuideNumber
									  
									  					INSERT INTO DeliveryBackOffice.dbo.WebhookTrackingQueueDetailForSFTP 
															(CustomerId,
															GuideSerie,
															GuideNumber,
															GuidePiece,
															ExternalNumber,
															ExternalPieceId,
															StatusOrderId,
															RowStatus,
															DateCreated,
															TokenCreated)
														SELECT @WebhookCustomerIdRec,
																dop.GuideSerie,
																dop.GuideNumber, 
																dop.GuidePiece, 
																do.Ticket_Number,
																dop.ExternalPieceId, 
																@GuideCurrentStatusRec, 
																1 AS RowStatus, 
																GETDATE()AS DateCreated,
																@Token AS TokenCreated
														FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
														INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
															ON dop.GuideSerie = do.Guide_Serie
															AND dop.GuideNumber = do.Guide_Number
														INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
														    ON do.IdCustomer = WHE.CustomerId
														INNER JOIN @GuidePiecesTableRec gpt
														    ON dop.GuideSerie = gpt.GuideSerie
															AND dop.GuideNumber = gpt.GuideNumber
														INNER JOIN @PiecesGuideRelatedTableRec pgt
														    ON gpt.GuideSerie = pgt.GuideSerie
															AND gpt.GuideNumber = pgt.GuideNumber
                                                            AND gpt.NumberPieces = pgt.NumberRelatedPieces
															WHERE gpt.NumberPieces = @MaxPieceOrderDetail
																AND WHE.TypeConnectionId = 2

								 END


							END

						END TRY
						BEGIN CATCH

						END CATCH
						-------------------WEBHOOK.FIN------------------------------


		END
        ---	 insertar checkpoint de arribo a instalaciones.	
	
			INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
			(
				[Guide_Serie],
				[Guide_Number],
				[StatusOrderId],
				[UserCreated],
				[DateCreated],
				[DateCreatedInSystem],
				[Observations],
				[Temperature_Celsius],
				[PieceId],
				[StationId]
			)
			VALUES
			(@GuideSerie, @GuideNumber, @stattus, @Token, GETDATE(), GETDATE(), NULL, NULL, @GuidePiece, @StationId);

			SET @RModified2 = @@rowcount;


	

        IF (@val = @valu)
        BEGIN
            UPDATE do
            SET do.StatusOrderId = @stattus
            FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber;
            SET @GModif = @@rowcount;

            -- Activar bandera de proceso de SMS
            -- Se comenta porque no está en uso
            IF (@stattus = 11) --En ruta, (11) Arribó a instalaciones
                IF (
                   (
                       SELECT TOP 1
                              ue.UpdateStatus
                       FROM [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue WITH (NOLOCK)
                       WHERE ue.RowStatus = 1
                             AND ue.ElementId = 1001
                   ) = 0
                   )
                BEGIN
                    UPDATE [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
                    SET UpdateStatus = 1,
                        UpdateDateTime = GETDATE()
                    WHERE RowStatus = 1
                          AND ElementId = 1001;
                END;

								-----------------WEBHOOK.INI-----------------------		
					DECLARE @WebhookCustomerId INT = -1;
					DECLARE @CustomerEndpointId INT = -1;
					-- Debido a que se procesa únicamente 1 guía
					DECLARE @GuideCurrentStatus INT = -1;

					BEGIN TRY
						DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.RowStatus = 1 AND WT.IdWebhookType = 1);--'GuideStatusChange'

						SET @WebhookCustomerId = ISNULL((SELECT TOP 1 DO.IdCustomer FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber),-1);
						SET @CustomerEndpointId = ISNULL((SELECT TOP 1 WE.IdWebhookEndpoint FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK) WHERE WE.CustomerId = @WebhookCustomerId AND  WE.WebhookTypeId = @GuideStatusChangeWebhook),-1);

						SET @GuideCurrentStatus = (SELECT TOP 1 DO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber );

						-- Cliente tiene webhook configurado para el tipo especificado
						-- Estado actual de la guía coincide dentro de las restricciónes por usuario
						IF ( @WebhookCustomerId > 0 AND @CustomerEndpointId > 0 AND @GuideCurrentStatus IN (SELECT WRBU.StatusOrderId FROM [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK) WHERE WRBU.CustomerId = @WebhookCustomerId AND WRBU.WebhookTypeId = @GuideStatusChangeWebhook) )
						BEGIN 

							DECLARE @ResponseTable AS TABLE (
								InsertedId BIGINT
							);

							DECLARE @TypeConnect INT = 0;

									SET @TypeConnect = (SELECT top 1 TypeConnectionId 
											FROM DeliveryBackOffice.dbo.WebhookEndpoint wh
											INNER JOIN DeliveryBackOffice.dbo.WebhookCatTypeConnection wc
												ON wh.TypeConnectionId = wc.IdCatTypeConnection
											WHERE wh.CustomerId = @WebhookCustomerId)

						IF(@TypeConnect = 1)
							 BEGIN

									INSERT INTO 
										[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
										(
											[GuideSerie]
											,[GuideNumber]
											,[CustomerId]
											,[StatusOrderId]
											,[WebhookEndpointId]
											,[HasNotified]
											,[TokenCreated]
											,[DateCreated]
										)
									OUTPUT inserted.IdWebhookTrackingQueue INTO @ResponseTable (InsertedId)
									VALUES
										(
											@GuideSerie
											,@GuideNumber
											,@WebhookCustomerId
											,@GuideCurrentStatus
											,@CustomerEndpointId
											,0
											,@Token
											,GETDATE()
										)
							 END
						ELSE
							 BEGIN
									-----------------------------------
												 DECLARE @GuidePiecesTable AS TABLE
												(
												    CustomerId INT,
												    CustomerEndpointId BIGINT,
												    WebhookType INT,
												    GuideSerie NVARCHAR(2),
												    GuideNumber INT,
												    GuideStatusId TINYINT,
													NumberPieces INT,
													NumberRelatedPieces INT
													
												);

												INSERT INTO @GuidePiecesTable 
															( 
														CustomerId,
												        GuideSerie,
												        GuideNumber,
												        GuideStatusId,
														NumberPieces
														)
														SELECT @WebhookCustomerId,
																dop.GuideSerie,dop.GuideNumber, 
																@GuideCurrentStatus,
																Count(dop.GuideNumber)
														FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
														INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
															ON do.Guide_Serie = dop.GuideSerie
															AND do.Guide_Number = dop.GuideNumber
														INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
															ON do.IdCustomer = WHE.CustomerId
														WHERE do.Guide_Serie = @GuideSerie 
                                                            AND do.Guide_Number = @GuideNumber
															AND WHE.TypeConnectionId = 2
														GROUP BY dop.GuideSerie,dop.GuideNumber

												   DECLARE @PiecesGuideRelatedTable AS TABLE
												(
												    CustomerId INT,
												    CustomerEndpointId BIGINT,
												    WebhookType INT,
												    GuideSerie NVARCHAR(2),
												    GuideNumber INT,
												    GuideStatusId TINYINT,
													NumberRelatedPieces INT
													
												);

												INSERT INTO @PiecesGuideRelatedTable 
															( 
														CustomerId,
												        GuideSerie,
												        GuideNumber,
												        GuideStatusId,
														NumberRelatedPieces
														)
														SELECT @WebhookCustomerId,
																dop.GuideSerie,
																dop.GuideNumber, 
																@GuideCurrentStatus,
																Count(dop.GuideNumber)
														FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
														INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
															ON dop.GuideSerie = do.Guide_Serie AND do.Guide_Number = dop.GuideNumber 
														INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
															ON do.IdCustomer = WHE.CustomerId
														WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber 
															AND dop.ExternalPieceId IS NOT NULL
															AND WHE.TypeConnectionId = 2
														GROUP BY dop.GuideSerie,dop.GuideNumber
								  
								  					INSERT INTO WebhookTrackingQueueDetailForSFTP 
														(CustomerId,
														GuideSerie,
														GuideNumber,
														GuidePiece,
														ExternalNumber,
														ExternalPieceId,
														StatusOrderId,
														RowStatus,
														DateCreated,
														TokenCreated)
													SELECT @WebhookCustomerId,
															dop.GuideSerie,
															dop.GuideNumber, 
															dop.GuidePiece, 
															do.Ticket_Number,
															dop.ExternalPieceId, 
															@GuideCurrentStatus, 1 AS RowStatus, 
															GETDATE()AS DateCreated,
															@Token AS TokenCreated
													FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
													INNER JOIN DeliveryOrder do WITH(NOLOCK)
														ON do.Guide_Serie = dop.GuideSerie AND dop.GuideNumber = do.Guide_Number
													INNER JOIN DeliveryBackOffice.dbo.WebhookEndpoint WHE WITH(NOLOCK)
													    ON do.IdCustomer = WHE.CustomerId
													INNER JOIN @GuidePiecesTable gpt
													    ON dop.GuideSerie = gpt.GuideSerie AND dop.GuideNumber = gpt.GuideNumber 
													INNER JOIN @PiecesGuideRelatedTable pgt
													    ON gpt.GuideSerie = pgt.GuideSerie AND gpt.GuideNumber = pgt.GuideNumber
														 AND gpt.NumberPieces = pgt.NumberRelatedPieces
														WHERE
														--	AND
															WHE.TypeConnectionId = 2

							 END

						END

					END TRY
					BEGIN CATCH

					END CATCH
					-------------------WEBHOOK.FIN------------------------------


        END;

        --Se marca como recolectado el servicio
        UPDATE sm
        SET ServiceStatusId = 3,
            TokenUpdated = @Token,
            DateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.ServiceManagement sm WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
        WHERE dopd.GuideSerie = @GuideSerie
              AND dopd.GuideNumber = @GuideNumber;

        --Validar si pertenece a un punto de visita
        DECLARE @tiempo DATE =
                (
                    SELECT CAST(GETDATE() AS DATE)
                );
        DECLARE @Sender_ID INT;
        DECLARE @SchedulePickupId BIGINT;
        DECLARE @dopdId BIGINT;
        DECLARE @ServiceManagementId INT;
        DECLARE @ServiceManagementIdFind INT;
        DECLARE @SchedulePickupIdFind BIGINT;
        DECLARE @RouteAssigment INT;
        DECLARE @RouteAssigmentFind INT;
        DECLARE @FindServiceManagement BIT = 0;
        DECLARE @CreateServiceManagement BIT = 0;
        DECLARE @ServiceStatus INT = 3; -- CatServiceStatus -> 'Recolectado'

        DECLARE @VehicleTypeId INT =
                (
                    SELECT cv.IdTypeVehicle
                    FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.CatVehicle cv
                            ON cv.IdVehicle = ra.IdVehicle
                    WHERE ra.IdRoute = @IdRoute
                          AND ra.DateOfRoute = @tiempo
                );

        --Validar que tenga registro en la DeliveryOrderPaymentDetail sino lo crea
        SELECT @dopdId = dopd.DopId,
               @SchedulePickupId = dopd.IdHeaderRecolection
        FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
        WHERE dopd.GuideSerie = @GuideSerie
              AND dopd.GuideNumber = @GuideNumber;

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
            --,[TypeService]
            --,[IdAccount]
            )
            SELECT @GuideNumber,
                   @GuideSerie,
                   CASE
                       WHEN do.IsCollect = 1 THEN
                       (
                           SELECT PayTypeId
                           FROM DeliveryBackOffice.dbo.CatPaymentType WITH (NOLOCK)
                           WHERE PayTypeAbrev = 'COLLT'
                       )
                       WHEN cu.ConditionOfPaymentID > 1 THEN
                       (
                           SELECT PayTypeId
                           FROM DeliveryBackOffice.dbo.CatPaymentType WITH (NOLOCK)
                           WHERE PayTypeAbrev = 'CREDT'
                       )
                       ELSE
                   (
                       SELECT PayTypeId
                       FROM DeliveryBackOffice.dbo.CatPaymentType WITH (NOLOCK)
                       WHERE PayTypeAbrev = 'CONT'
                   )
                   END,
                   CASE
                       WHEN do.IsCollect = 1 THEN
                           1
                       WHEN cu.ConditionOfPaymentID > 1 THEN
                           8
                       ELSE
                           1
                   END,
                   CASE
                       WHEN do.IsCollect = 1 THEN
                       (
                           SELECT TimePlaId
                           FROM DeliveryBackOffice.dbo.CatPaymentTime WITH (NOLOCK)
                           WHERE TimePlaAbrev = 'DEST'
                       )
                       WHEN cu.ConditionOfPaymentID > 1 THEN
                       (
                           SELECT TimePlaId
                           FROM DeliveryBackOffice.dbo.CatPaymentTime WITH (NOLOCK)
                           WHERE TimePlaAbrev = 'POST'
                       )
                       ELSE
                   (
                       SELECT TimePlaId
                       FROM DeliveryBackOffice.dbo.CatPaymentTime WITH (NOLOCK)
                       WHERE TimePlaAbrev = 'AHR'
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
                   NULL,
                   NULL,
                   NULL,
                   NULL
            --,NULL
            --,NULL
            FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.Customer cu WITH (NOLOCK)
                    ON cu.IdCustomer =
                    (
                        SELECT TOP 1
                               ISNULL(do.IdCustomer, vpc.CustomerID)
                        FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                        WHERE vpc.CodeOfReference = do.Sender_ID
                    )
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber;

            SET @dopdId = SCOPE_IDENTITY();
        END;

        --Validar si pertenece a un punto de visita para buscar si ya existe el servicio
        SELECT @Sender_ID = do.Sender_ID
        FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
        WHERE do.Guide_Serie = @GuideSerie
              AND do.Guide_Number = @GuideNumber;

        --Si tiene un SchedulePickup buscar si ya está asignado a un servicio y si es el correcto
        IF @SchedulePickupId IS NOT NULL
        BEGIN

            UPDATE DeliveryBackOffice.dbo.SchedulePickup
            SET AssigmentStatus = 1,
                TokenUpdated = @Token,
                DateUpdated = GETDATE()
            WHERE SchedulePickupId = @SchedulePickupId;

            --Buscar si tiene asignado un servicio
            SELECT @ServiceManagementId = sm.IdServiceManagement
            FROM DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
            WHERE sm.IdSchedulePickup = @SchedulePickupId;

            --Si encontró el servicio
            IF @ServiceManagementId IS NOT NULL
            BEGIN

                --Válidar que este asignado a la ruta
                IF EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
                            ON sm.IdPuRouteAssigment = ra.IdRouteAssigment                              
                    WHERE ra.IdRoute = @IdRoute
                          AND ra.DateOfRoute = @tiempo
						  AND sm.IdServiceManagement = @ServiceManagementId
                )
                BEGIN
                    --Se marca como recolectado
                    UPDATE sm
                    SET ServiceStatusId = 3,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    FROM DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
                    WHERE sm.IdServiceManagement = @ServiceManagementId;

                    --Insertar EventService si no existe
                    IF NOT EXISTS
                    (
                        SELECT 1
                        FROM DeliveryBackOffice.dbo.EventService es WITH(NOLOCK)
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

                END;
                ELSE
                BEGIN
                    SET @FindServiceManagement = 1;
                END;
            END;
            ELSE
            BEGIN
                SET @FindServiceManagement = 1;
            END;
        END;
        ELSE
        BEGIN
            SET @FindServiceManagement = 1;
        END;

        --Si se tiene que buscar si un servicio si coincide con el vp
        IF @FindServiceManagement = 1
        BEGIN

            IF @Sender_ID IS NOT NULL
               AND @Sender_ID <> 0
            BEGIN
                SELECT @SchedulePickupIdFind = sm.IdSchedulePickup,
                       @ServiceManagementIdFind = sm.IdServiceManagement
                FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
                        ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
                    INNER JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH(NOLOCK)
                        ON sp.SchedulePickupId = sm.IdSchedulePickup
                WHERE ra.IdRoute = @IdRoute
                      AND ra.DateOfRoute = @tiempo
                      AND sp.SenderId = @Sender_ID;
            END;
            ELSE
            BEGIN
                --Buscar por Dirección
                SELECT @SchedulePickupIdFind = sm.IdSchedulePickup,
                       @ServiceManagementIdFind = sm.IdServiceManagement
                FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH(NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
                        ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
                    INNER JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH(NOLOCK)
                        ON sp.SchedulePickupId = sm.IdSchedulePickup
                    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                        ON sp.AddressPickup = do.Sender_Address
                WHERE ra.IdRoute = @IdRoute
                      AND ra.DateOfRoute = @tiempo
					  AND do.Guide_Serie = @GuideSerie
                           AND do.Guide_Number = @GuideNumber;
            END;

            --Si se encuentra el vp entre los servicios de recolección, se asigna
            IF @SchedulePickupIdFind IS NOT NULL
            BEGIN
                UPDATE DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail
                SET IdHeaderRecolection = @SchedulePickupIdFind,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE GuideSerie = @GuideSerie
                      AND GuideNumber = @GuideNumber;

                --Se marca como recolectado
                UPDATE sm
                SET ServiceStatusId = 3,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                FROM DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
                WHERE sm.IdSchedulePickup = @SchedulePickupIdFind;

                UPDATE DeliveryBackOffice.dbo.SchedulePickup
                SET AssigmentStatus = 1,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE SchedulePickupId = @SchedulePickupIdFind;

                --Insertar EventService si no existe
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.EventService es WITH(NOLOCK)
                    WHERE es.ServiceManagementId = @ServiceManagementIdFind
                          AND es.ServiceStatusId = @ServiceStatus
                          AND es.RowStauts = 1
                )
                BEGIN
                    INSERT INTO DeliveryBackOffice.dbo.EventService
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
                END;
            END;
            ELSE
            BEGIN
                SET @CreateServiceManagement = 1;
            END;
        END;

        --Si se tiene que crear el servicio
        IF @CreateServiceManagement = 1
        BEGIN
            -- Si no tiene un SchedulePicku, lo crea y lo asigna
            IF @SchedulePickupId IS NULL
            BEGIN

                INSERT INTO [dbo].[SchedulePickup]
                (
                    [AccountId],
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
                    [IsScheduled]
                )
                SELECT TOP 1
                       acc.AccIdAccount,
                       CONCAT(CAST(GETDATE() AS DATE), ' 08:00:00'),
                       CONCAT(CAST(GETDATE() AS DATE), ' 17:00:00'),
                       0,
                       0,
                       0,
                       0,
                       '',
                       1,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL,
                       do.Sender_ID,
                       CONCAT(
                                 ISNULL(do.Sender_FirstName, ''),
                                 IIF(do.Sender_FirstName IS NULL, '', IIF(do.Sender_LastName IS NULL, '', ' ')),
                                 ISNULL(do.Sender_LastName, '')
                             ),
                       do.Sender_Phone,
                       NULL, -- [IdHubLogistics]
                       NULL, -- [AmountPickup]
                       2,    -- [IdSourcePlataform]
                       do.Sender_Address,
                       1,
                       NULL, --TransaccionFAC
                       NULL, --TownshipId
                       1,
                       @VehicleTypeId,
                       0
                FROM DeliveryBackOffice.dbo.DeliveryOrder do  WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.Account acc
                        ON acc.IdCustomer =
                        (
                            SELECT TOP 1
                                   ISNULL(do.IdCustomer, vpc.CustomerID)
                            FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                            WHERE vpc.CodeOfReference = do.Sender_ID
                        )
                WHERE do.Guide_Serie = @GuideSerie
                      AND do.Guide_Number = @GuideNumber;

                SET @SchedulePickupId = SCOPE_IDENTITY();

                UPDATE DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail
                SET IdHeaderRecolection = @SchedulePickupId,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE DopId = @dopdId;
            END;
            ELSE
            BEGIN
                UPDATE DeliveryBackOffice.dbo.SchedulePickup
                SET AssigmentStatus = 1,
                    TypeVehicleId = @VehicleTypeId,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE SchedulePickupId = @SchedulePickupId;
            END;

            --si ya tiene un servicio, solo lo reasigna
            IF @ServiceManagementId IS NOT NULL
            BEGIN
                UPDATE sm
                SET sm.IdPuRouteAssigment = ra.IdRouteAssigment,
                    sm.TokenUpdated = @Token,
                    sm.DateUpdated = GETDATE()
                FROM DeliveryBackOffice.dbo.ServiceManagement sm WITH(NOLOCK)
                CROSS APPLY (
                    SELECT TOP 1 IdRouteAssigment
                    FROM DeliveryBackOffice.dbo.RouteAssigment WITH(NOLOCK)
                    WHERE IdRoute = @IdRoute
                      AND DateOfRoute = @tiempo
                ) ra
                WHERE sm.IdServiceManagement = @ServiceManagementId;

                --Se marca como recolectado
                UPDATE sm
                SET ServiceStatusId = 3,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                FROM DeliveryBackOffice.dbo.ServiceManagement sm
                WHERE sm.IdServiceManagement = @ServiceManagementId;

                --Insertar EventService si no existe
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.EventService es WITH(NOLOCK)
                    WHERE es.ServiceManagementId = @ServiceManagementId
                          AND es.ServiceStatusId = @ServiceStatus
                          AND es.RowStauts = 1
                )
                BEGIN
                    INSERT INTO DeliveryBackOffice.dbo.EventService
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

            END;
            ELSE
            BEGIN
                --Crea el servicio y lo asigna
                INSERT INTO [dbo].[ServiceManagement]
                (
                    [IdPuCourrier],
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
                    [Order]
                )
                SELECT ra.IdCurrierMan,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       ra.IdRouteAssigment,
                       NULL,
                       @SchedulePickupId,
                       NULL,
                       1,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL,
                       3,
                       NULL,
                       NULL,
                       1,
                       NULL,
                       1
                FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH (NOLOCK)
                WHERE ra.IdRoute = @IdRoute
                      AND ra.DateOfRoute = @tiempo;

                SET @ServiceManagementId = SCOPE_IDENTITY();

                --Insertar EventService si no existe
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.EventService es WITH(NOLOCK)
                    WHERE es.ServiceManagementId = @ServiceManagementId
                          AND es.ServiceStatusId = @ServiceStatus
                          AND es.RowStauts = 1
                )
                BEGIN
                    INSERT INTO DeliveryBackOffice.dbo.EventService
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
            END;
        END;
		
		

    END TRY
    BEGIN CATCH
        IF EXISTS
        (
            SELECT 1
            FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
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
               0 'IsDry',
			   @IsStatusTerminal 'IsTerminal'
        ROLLBACK TRANSACTION;

        SELECT 'No se guardo el registro' AS StatusCode;
    --select ERROR_MESSAGE()
    -- retornar mensaje de error


    END CATCH;
    IF @@trancount > 0
    BEGIN

        IF (@RModified > 0 AND @RModified2 > 0)
        BEGIN

            SELECT 1 AS 'StatusCode',
			        @Description 'Description',
                   @GuideSerie GuideSerie,
                   @GuideNumber GuideNumber,
                   @GuidePiece GuidePiece,
                   @IsDry 'IsDry',
                   COALESCE(do.Pieces_Dry, 0) + COALESCE(do.Pieces_Cold, 0) Pieces,
				   1 'IsTerminal'
            FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber;


            SELECT @GModif AS CONT;

            SELECT (CASE
                        WHEN do.Manifest_Serie IS NOT NULL
                             AND do.Manifest_Number IS NOT NULL THEN
                            CONCAT(do.Manifest_Serie, '-', do.Manifest_Number)
                        ELSE
                            ''
                    END
                   ) MANIFIESTO,
                   ISNULL(sp.SenderName, vpc.DescriptionOfClient) REMITENTE,
                   ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0) PIECE
            --,vpc.CodeOfReference CodeOfReference
            FROM DeliveryBackOffice.dbo.RouteAssigment ra WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.ServiceManagement sm WITH (NOLOCK)
                    ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
                INNER JOIN DeliveryBackOffice.dbo.SchedulePickup sp WITH (NOLOCK)
                    ON sp.SchedulePickupId = sm.IdSchedulePickup
                INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = sp.SenderId
                LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                    ON dopd.IdHeaderRecolection = sp.SchedulePickupId
                LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                    ON do.Guide_Serie = dopd.GuideSerie
                       AND do.Guide_Number = dopd.GuideNumber
            WHERE ra.IdRoute = @IdRoute
                  AND ra.DateOfRoute = @tiempo;

            COMMIT TRANSACTION;
        END;

        ELSE
        BEGIN
            IF @RModified3 = 0 
            BEGIN
                DECLARE @Status NVARCHAR(100);

                SELECT @Status = so.OrderDescription
                FROM DeliveryBackOffice.dbo.DeliveryOrderPiece do WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                        ON so.StatusOrderId = do.StatusOrderId
                WHERE do.GuideSerie = @GuideSerie
                      AND do.GuideNumber = @GuideNumber
                      AND do.NoPiece = @GuidePiece;
                --AND do.StatusOrderId IN ( 7, 11, 5, 4, 12, 18);

                IF @Status IS NOT NULL
                BEGIN
                    SET @Description
                        = CONCAT(
                                    'La pieza ',
                                    @GuideSerie,
                                    @GuideNumber,
                                    '-',
                                    @GuidePiece,
                                    ' se encuentra en estado: ',
                                    @Status,
                                    '.'
                                );

                    IF @Status IN ( 'En ruta', 'Entregado' )
                        SET @Description = CONCAT(@Description, ' Debe liquidarla en la liquidación de entregas.');
                END;
                ELSE IF EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.DeliveryOrderPiece WITH (NOLOCK)
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                          AND NoPiece = @GuidePiece
                )
                BEGIN
                    SELECT @Status = so.OrderDescription
                    FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.StatusOrder so
                            ON so.StatusOrderId = do.StatusOrderId
                    WHERE do.Guide_Serie = @GuideSerie
                          AND do.Guide_Number = @GuideNumber;

                    IF @Status IS NOT NULL
                    BEGIN
                        SET @Description
                            = CONCAT(
                                        'La pieza ',
                                        @GuideSerie,
                                        @GuideNumber,
                                        '-',
                                        @GuidePiece,
                                        ' se encuentra en estado: ',
                                        @Status,
                                        '.'
                                    );

                        IF @Status IN ( 'En ruta', 'Entregado' )
                            SET @Description = CONCAT(@Description, ' Debe liquidarla en la liquidación de entregas.');
                    END;
                    ELSE
                        SET @Description = N'Error: INSERT INTO TransactionalBackbone.';
                END;
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
                   0 'IsDry',
				   @IsStatusTerminal 'IsTerminal'
            ROLLBACK TRANSACTION;
        END;
    END;
END; 

END
